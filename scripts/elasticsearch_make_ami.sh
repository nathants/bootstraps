#!/bin/bash
set -eu

hash=${hash:-$(curl -XGET -L https://api.github.com/repos/nathants/bootstraps/commits 2>/dev/null|jq .[0].sha -r)}
hash=$(echo $hash|head -c7)

cd $(dirname $0)
source _prompt.sh

link=http://github.com/nathants/bootstraps/blob/$hash/scripts/elasticsearch.sh

prompt hash link

yes=y tag=hash=$hash description=$link bash make_ami.sh elasticsearch "
  curl -L https://github.com/nathants/bootstraps/tarball/$hash | tar zx
  bash nathants-bootstraps*/scripts/elasticsearch.sh 5.0.0 ami-cluster
"
