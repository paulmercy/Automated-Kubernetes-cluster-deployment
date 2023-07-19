#! /bin/bash

bar_status=$(kubectl get pods --selector=app=bar -o json | jq -r '.items[0].status.phase')
foo_status=$(kubectl get pods --selector=app=foo -o json | jq -r '.items[0].status.phase')


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
