#!/usr/bin/env bash

# Import functions
SCRIPT_DIR="$(dirname "${0}")"
. "${SCRIPT_DIR}/backup-utils.sh"

# BASH STRICT MODE
set -o errexit # abort on nonzero exitstatus
set -o nounset # abort on unbound variable
set -o pipefail

excludedDatasets="$(getExcludedDirsFromArgs "$@")"

allDatasets="$(getAllZfsDatasets)"

IFS=$'\n'
for dataset in ${allDatasets}; do
	if contains "${excludedDatasets}" "${dataset}"; then
		continue
	fi

	timestamp=$(date +"%Y-%m-%d_%H:%M:%S")
	snapshotName="${dataset}@${timestamp}"

	zfs snapshot "${snapshotName}"

	echo "Successfully created snapshot '${snapshotName}'"
done
