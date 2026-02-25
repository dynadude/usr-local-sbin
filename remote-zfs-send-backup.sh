#!/usr/bin/env bash

# Import functions
SCRIPT_DIR="$(dirname "${0}")"
. "${SCRIPT_DIR}/backup-utils.sh"

# BASH STRICT MODE
set -o errexit # abort on nonzero exitstatus
set -o nounset # abort on unbound variable
set -o pipefail

REMOTE_SERVER='192.168.1.231'
REMOTE_BACKUP_DIR='/var/storage/sagi/sagi-pc-backups'
OUTPUT_FILE_NAME='zfs-send-output'

dataset="${1}"
remoteDirName="${2}"

snapshot="$(getLatestZfsSnapshot "${dataset}")"

# The cat is there to make the shell wait for process substitution
zfs send --raw --replicate "${snapshot}" |
	tee >/dev/null \
		>(echo "source file size: $(wc -c | numfmt --to=si)") \
		>(echo "source hash: $(sha1sum)") \
		>(ssh "${REMOTE_SERVER}" 'tee >/dev/null >(echo "destination hash: $(sha1sum)") '"'${REMOTE_BACKUP_DIR}/${remoteDirName}/${OUTPUT_FILE_NAME}'") |
	cat

echo "Successfully backed up '${snapshot}'"
