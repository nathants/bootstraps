#!/bin/bash
set -e

dst=$1
head=$2
tail=$3
head_escaped=$(echo "$head" | sed -r 's/([:\/\*\+\?])/\\\1/')
tail_escaped=$(echo "$tail" | sed -r 's/([:\/\*\+\?])/\\\1/')
uncommented_config() {
    sed -n "/^ *[^#\/\;]*${head_escaped}/p" ${dst}
}
[ -f $dst ] || (sudo touch $dst && echo created: $dst)
if [ -z "$(uncommented_config)" ]; then
    echo  appended to config: ${dst}
    echo "$head $tail" | sudo tee -a ${dst} >/dev/null
    echo "" new: "$(uncommented_config)"
else
    echo update config: ${dst}
    echo "" old: "$(uncommented_config)"
    sudo sed -i "s:${head_escaped}.*:${head_escaped} ${tail_escaped}:" ${dst}
    echo "" new: "$(uncommented_config)"
fi
