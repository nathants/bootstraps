#!/bin/bash
set -e

bootstraps=$(dirname $0)
bash $bootstraps/lein_java8.sh
bash $bootstraps/python34.sh
