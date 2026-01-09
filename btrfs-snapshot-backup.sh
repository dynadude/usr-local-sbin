#!/usr/bin/env bash

# BASH STRICT MODE
set -o errexit # abort on nonzero exitstatus
set -o nounset # abort on unbound variable
set -o pipefail

sourcePath="${1-}"
snapshotPrefix="${2-}"

# ARGUMENT VALIDATION
if [ -z "${sourcePath}" ]; then
	echo 'The source dir to back up was not specified. Exiting...' >&2
	exit 1
fi

if ! [ -d "${sourcePath}" ]; then
	echo 'The specified source dir to back up does not exist or is not a directory. Exiting...' >&2
	exit 2
fi

# snapshot prefix default value
if [ -z "${snapshotPrefix}" ]; then
	echo 'The snapshot prefix was not specified. Using ".backups/"...'
	snapshotPrefix='.backups/'
fi

targetDir="${sourcePath}/${snapshotPrefix}$(date +"%Y-%m-%d_%H:%M:%S")"

btrfs subvolume snapshot -r "${sourcePath}" "${targetDir}"
