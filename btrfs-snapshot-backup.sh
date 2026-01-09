#!/usr/bin/env bash

# BASH STRICT MODE
set -o errexit # abort on nonzero exitstatus
set -o nounset # abort on unbound variable
set -o pipefail

SRC_PATH="${1-}"
SNAPSHOT_PREFIX="${2-}"

# ARGUMENT VALIDATION
if [ -z "$SRC_PATH" ]; then
	echo 'The source dir to back up was not specified. Exiting...' >&2
	exit 1
fi

if ! [ -d "$SRC_PATH" ]; then
	echo 'The specified source dir to back up does not exist or is not a directory. Exiting...' >&2
	exit 2
fi

# snapshot prefix default value
if [ -z "$SNAPSHOT_PREFIX" ]; then
	echo 'The snapshot prefix was not specified. Using ".backups/"...'
	SNAPSHOT_PREFIX='.backups/'
fi

TARGET_DIR="${SRC_PATH}/${SNAPSHOT_PREFIX}$(date +"%Y-%m-%d_%H:%M:%S")"

btrfs subvolume snapshot -r "${SRC_PATH}" "${TARGET_DIR}"
