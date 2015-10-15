#!/bin/bash
set -e

set_opt() {
    dst=$1
    head=$2
    tail=$3
    sudo sed -i "/${head}/d" ${dst}
    sudo sed -i "$ a ${head} ${tail}" ${dst}
    echo updated \"${head} ${tail}\" in ${dst}
}
