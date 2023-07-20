#! /bin/bash

# set -x
LAUNCH_DIR=$(pwd); SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"; cd $SCRIPT_DIR; cd ..; SCRIPT_PARENT_DIR=$(pwd);

bar_status=$(kubectl get pods --selector=app=http-echo -o json | jq -r '.items[0].status.phase')
foo_status=$(kubectl get pods --selector=app=http-echo -o json | jq -r '.items[0].status.phase')


if [[ "$bar_status" !=  "Running" ]]; then
  echo "Bar is NOT running"
else
   echo "Bar is running OK"
fi

if [[ "$foo_status" !=  "Running" ]]; then
  echo "Foo is NOT running"
else
   echo "Foo is running OK"
fi
