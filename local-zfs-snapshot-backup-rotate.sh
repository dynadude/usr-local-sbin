#!/usr/bin/env bash

# Import functions
SCRIPT_DIR="$(dirname "${0}")"
. "${SCRIPT_DIR}/backup-utils.sh"

# BASH STRICT MODE
set -o errexit # abort on nonzero exitstatus
set -o nounset # abort on unbound variable
set -o pipefail

backupsToKeep="${1}"
excludedDatasets="$(getExcludedDirsFromArgs "$@")"

allDatasets="$(getAllZfsDatasets)"

IFS=$'\n'
for dataset in ${allDatasets}; do
	if contains "${excludedDatasets}" "${dataset}"; then
		continue
	fi

	dirsToRemove=$(zfs list -t snapshot -H -o name "${dataset}" | head -n -"${backupsToKeep}")

	if [ -n "${dirsToRemove}" ]; then
		echo 'Removing Backups:'
		echo "${dirsToRemove}"
		echo "${dirsToRemove}" | xargs -n1 zfs destroy
	else
		echo "No Backups to Remove for '${dataset}'"
	fi
done
