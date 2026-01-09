#!/usr/bin/env bash

# BASH STRICT MODE
set -o errexit # abort on nonzero exitstatus
set -o nounset # abort on unbound variable
set -o pipefail

TIMESTAMP=$(date +"%Y-%m-%d_%H:%M:%S")
snapshotName="storage-zpool/storage@${TIMESTAMP}"

zfs snapshot "${snapshotName}"
