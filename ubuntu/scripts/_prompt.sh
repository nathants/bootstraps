#!/bin/bash
set -eu

prompt() {
    # usage:
    # > source ./_prompt.sh
    # > foo=bar
    # > num=3
    # > prompt foo num
    # >> foo: bar
    # >> instance_type: m3.xlarge
    # >>
    # >> proceed? y/n
    for x in $@; do echo ${x}: ${!x} 1>&2; done
    [ "${yes:-n}" = "y" ] || (echo -e "\nproceed? y/n" && read -n1 answer && echo && [ $answer = y ] && echo -e '\nproceeding...\n' || (echo -e '\naborting...\n' && exit 1))
}
