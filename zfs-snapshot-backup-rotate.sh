#!/usr/bin/env bash

# BASH STRICT MODE
set -o errexit # abort on nonzero exitstatus
set -o nounset # abort on unbound variable
set -o pipefail

dataset="${1}"
backupsToKeep="${2-}"
# backups to keep default value
if [ -z "$backupsToKeep" ]; then
	backupsToKeep=30
	echo "The amount of backups to keep was not specified. Using ${backupsToKeep}..."
fi

dirsToRemove=$(zfs list -t snapshot -o name "${dataset}" | tail -n +2 | head -n -"${backupsToKeep}")

if [ -n "${dirsToRemove}" ]; then
	echo 'Removing Backups:'
	echo "${dirsToRemove}"
	echo "${dirsToRemove}" | xargs -n1 zfs destroy
else
	echo 'No Backups to Remove'
fi
