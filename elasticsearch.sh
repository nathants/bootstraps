#!/bin/bash
set -e

bootstraps=$(dirname $0)
source ${bootstraps}/set_opt.sh

path=/etc/elasticsearch/elasticsearch.yml

set_opt ${path} path.conf: /etc/elasticsearch
set_opt ${path} path.data: /data/elasticsearch
set_opt ${path} path.logs: /var/log/elasticsearch

set_opt ${path} bootstrap.mlockall: true

set_opt ${path} discovery.zen.minimum_master_nodes: 2
set_opt ${path} discovery.zen.ping.multicast.enabled: true

set_opt ${path} threadpool.search.type: fixed
set_opt ${path} threadpool.search.size: 10
set_opt ${path} threadpool.search.queue_size: 100

set_opt ${path} threadpool.bulk.type: fixed
set_opt ${path} threadpool.bulk.size: 30
set_opt ${path} threadpool.bulk.queue_size: 300

set_opt ${path} threadpool.index.type: fixed
set_opt ${path} threadpool.index.size: 10
set_opt ${path} threadpool.index.queue_size: 100

set_opt ${path} indices.memory.index_buffer_size: 50%
set_opt ${path} indices.memory.min_shard_index_buffer_size: 12mb
set_opt ${path} indices.memory.min_index_buffer_size: 96mb

set_opt ${path} indices.fielddata.cache.size: 15%
set_opt ${path} indices.fielddata.cache.expire: 6h
set_opt ${path} indices.cache.filter.size: 15%
set_opt ${path} indices.cache.filter.expire: 6h

set_opt ${path} index.refresh_interval: 30s
set_opt ${path} index.translog.flush_threshold_ops: 50000
