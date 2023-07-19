#!/bin/bash

# Install hey
go get -u github.com/rakyll/hey

# Run load test
hey -n 1000 -c 100 http://bar.localhost > foo_results.txt
hey -n 1000 -c 100 http://foo.localhost > bar_results.txt

# Post the output of the load testing result as a comment on the GitHub Pull Request
gh pr comment ${GH_PR_NUMBER} --body "$(cat foo_results.txt)"
gh pr comment ${GH_PR_NUMBER} --body "$(cat bar_results.txt)"
