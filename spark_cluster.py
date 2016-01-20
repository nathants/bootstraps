# requires https://github.com/nathants/py-aws
import aws.ec2
import util.log

with util.log.disable('botocore', 'boto3'):
    instance_ids = aws.ec2.new(
        'spark',
        cmd='aws s3 cp s3://<bucket-name>/software/spark-1.6.0-bin-hadoop2.4.tgz . --quiet && tar xf spark*',
        spot=.25,
        tty=True,
        type='m4.xlarge',
        num=10,
    )
    master, *slaves = instance_ids
    master_ip = aws.ec2.ip(master)[0]
    master_private_ip = aws.ec2.ip_private(master)[0]
    aws.ec2.tag(master, 'type=master', yes=True)
    aws.ec2.tag(','.join(slaves), 'type=slave', yes=True)
    aws.ec2.ssh(master, cmd='cd spark* && SPARK_PUBLIC_DNS=$(curl http://169.254.169.254/latest/meta-data/public-hostname/ 2>/dev/null) ./sbin/start-master.sh')
    aws.ec2.ssh(*slaves, cmd='cd spark* && SPARK_PUBLIC_DNS=$(curl http://169.254.169.254/latest/meta-data/public-hostname/ 2>/dev/null) ./sbin/start-slave.sh spark://%(master_private_ip)s:7077' % locals())
    print('master ui: http://%(master_ip)s:8080' % locals())
    print('master url: spark://%(master_ip)s:7077' % locals())
