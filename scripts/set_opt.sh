#!/bin/bash
set -e

dst=$1
head=$2
tail=$3
head_escaped=$(echo "$head" | sed -r 's/([:\/\*\+\?])/\\\1/')
tail_escaped=$(echo "$tail" | sed -r 's/([:\/\*\+\?])/\\\1/')
uncommented_config() {
    sudo cat ${dst} | grep -vP '^ *[#\/\;]' |  sed -n -- "/^\s*${head_escaped}/p"
}
[ "$(uncommented_config | wc -l)" -le "1" ] || (echo ERROR mulptile matches! $dst $head; uncommented_config; exit 1)
[ -f $dst ] || (sudo touch $dst && echo created: $dst)
if [ -z "$(uncommented_config)" ]; then
    echo  appended to config: ${dst}
    echo "${head}${tail}" | sudo tee -a ${dst} >/dev/null
    echo "" new: "$(uncommented_config)"
else
    echo update config: ${dst}
    echo "" old: "$(uncommented_config)"
    sudo sed -ri "s:^(\s*)${head_escaped}.*:\1${head_escaped}${tail_escaped}:" ${dst}
    echo "" new: "$(uncommented_config)"
fi
