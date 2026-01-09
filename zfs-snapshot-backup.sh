#!/usr/bin/env bash

# BASH STRICT MODE
set -o errexit # abort on nonzero exitstatus
set -o nounset # abort on unbound variable
set -o pipefail

dataset="${1}"

timestamp=$(date +"%Y-%m-%d_%H:%M:%S")
snapshotName="${dataset}@${timestamp}"

zfs snapshot "${snapshotName}"

echo "Successfully created snapshot '${snapshotName}'"
