#!/bin/bash
# requires https://github.com/nathants/py-aws
# requires py-aws ec2 new to have defaults for --key, --vpc, and --sg. ec2 new -h will prompt you on first use, or edit ~/.*.aws.ec2.yaml
# requires an ec2 iam role with ec2 read access named: ec2-read-only
# requires https://stedolan.github.io/jq/

set -eu

# cd to this files parent, so we can access ./files
cd $(dirname $0)
source ./_prompt.sh

cluster_name=$1
num_new_instances=$2
ami=$3
ec2_type=$4
ec2_gigs=$5
spot_price=$6

if [ ! -z "$spot_price" ]; then
    spot_price="--spot $spot_price"
fi

num_existing_instances=$(ec2 ls -s running cluster-name=$cluster_name|wc -l)

num_instances=$((num_new_instances + num_existing_instances))

min_master=$(($num_instances / 2 + 1))

prompt ami cluster_name num_existing_instances num_new_instances num_instances ec2_type ec2_gigs spot_price min_master

name="elasticsearch-${cluster_name}"

ids=$(ec2 new $name \
          cluster-name=$cluster_name \
          $spot_price \
          --ami $ami \
          --type $ec2_type \
          --gigs $ec2_gigs \
          --num $num_new_instances \
          --role ec2-read-only)

# update yml config cluster wide
ec2 ssh cluster-name=$cluster_name -yc "
rm -rf bootstraps && curl -L https://github.com/nathants/bootstraps/tarball/master | tar zx && mv nathants-bootstraps* bootstraps
bash bootstraps/scripts/set_opt.sh /etc/elasticsearch/elasticsearch.yml 'cluster.name:' ' ${cluster_name}'
bash bootstraps/scripts/set_opt.sh /etc/elasticsearch/elasticsearch.yml 'discovery.ec2.tag.cluster-name:' ' ${cluster_name}'
bash bootstraps/scripts/set_opt.sh /etc/elasticsearch/elasticsearch.yml 'discovery.zen.minimum_master_nodes:' ' ${min_master}'
bash bootstraps/scripts/set_opt.sh /etc/elasticsearch/elasticsearch.yml 'gateway.recover_after_nodes:' ' ${num_instances}'
"

# update and restart new nodes
ec2 ssh $ids -yc - <<'EOF'
heap=$(free -m|head -2|tail -1|awk '{print $2}'|python2.7 -c 'import sys; print int(int(sys.stdin.read()) * .5)')
region=$(curl http://169.254.169.254/latest/meta-data/placement/availability-zone/ 2>/dev/null|sed s:.$::)
bash bootstraps/scripts/set_opt.sh /etc/default/elasticsearch 'ES_JAVA_OPTS=' "'-Xms${heap}m -Xmx${heap}m'"
bash bootstraps/scripts/set_opt.sh /etc/elasticsearch/elasticsearch.yml 'cloud.aws.region:' " ${region}"
sudo service elasticsearch restart
EOF

# wait for all nodes
ips=$(ec2 ip cluster-name=$cluster_name)
for i in {1..21}; do
    [ $i = 21 ] && echo ERROR all nodes never came up && false
    num_nodes_should_exist=$(for ip in $ips; do echo ${num_instances}; done)
    num_nodes_exist=$(for ip in $ips; do curl $ip:9200/_cluster/state 2>/dev/null|jq '.nodes|length'; done)
    colors=$(for ip in $ips; do echo $((curl $ip:9200/_cluster/health 2>/dev/null || echo '{"status": "failed"}') | jq '.status // "offline"' -r | head -c1); done | sort | uniq)
    echo wanted to see nodes: $num_nodes_should_exist
    echo actually saw nodes: $num_nodes_exist
    echo wanted to see colors: g
    echo actually saw colors: $colors
    [ "$colors" = "g" ] && [ "$num_nodes_should_exist" = "$num_nodes_exist" ] && echo all nodes up and green && break
    sleep 10
done

# update min-master cluster wide
echo set min master to: $min_master
for ip in $ips; do
    echo $ip $(curl -XPUT $ip:9200/_cluster/settings -d "{\"persistent\" : {\"discovery.zen.minimum_master_nodes\" : $min_master}}" 2>/dev/null|| echo fail)
done
