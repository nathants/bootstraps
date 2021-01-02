#!/bin/bash
set -euo pipefail

if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
    echo idempotently ensure that a given line with prefix has suffix
    echo usage: preview=y set-opt PREFIX SUFFIX
    echo usage: set-opt PREFIX SUFFIX
    echo usage: 'set-opt /tmp/my.conf some.setting " = 123"'
    exit 1
fi

file=$1
prefix=$2
suffix=$3

head_escaped=$(echo "$prefix" | sed -r 's/([\:\/\*\+\?])/\\\1/g')
tail_escaped=$(echo "$suffix" | sed -r 's/([\:\/\*\+\?])/\\\1/g')

line() {
    sudo cat $1 | grep -vP '^ *[#\/\;]' | sed -n -- "/^\s*${head_escaped}/p"
}

if [ ! "$(line $file | wc -l)" -le "1" ]; then
    echo ERROR mulptile matches! $file $prefix
    line $file
    exit 1
fi

if [ ! -f $file ]; then
    sudo touch $file
    echo created: $file
fi

if [ -z "$(line $file)" ]; then
    echo appended to config: ${file}
    echo "${prefix}${suffix}" | sudo tee -a ${file} >/dev/null
    echo "" new: "$(line $file)"
else
    tmpfile=$(mktemp)
    trap "rm -f $tmpfile" EXIT
    sed -r "s:^(\s*)${head_escaped}.*:\1${head_escaped}${tail_escaped}:" ${file} > $tmpfile

    if [ "$(line $file)" != "$(line $tmpfile)" ]; then
        if env | grep '^preview=' &>/dev/null; then
            echo preview update config: ${file}
            echo "" old: "$(line $file)"
            echo "" new: "$(line $tmpfile)"
        else
            echo update config: ${file}
            echo "" old: "$(line $file)"
            echo "" new: "$(line $tmpfile)"
            cat $tmpfile | sudo tee $file >/dev/null
        fi

    else
        echo config already valid: ${file} "$(line $file)"
    fi
fi
