#!/bin/bash
PR_ID=$(gh pr view --json number -q .number)
RESULTS=$(cat /path/to/results/file) # replace with the actual location of your results file
gh pr comment $PR_ID --body "$RESULTS"
