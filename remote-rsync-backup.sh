#!/usr/bin/env bash

# Import functions
SCRIPT_DIR="$(dirname "${0}")"
. "${SCRIPT_DIR}/backup-utils.sh"

# BASH STRICT MODE
set -o errexit # abort on nonzero exitstatus
set -o nounset # abort on unbound variable
set -o pipefail

# GLOBALS
REMOTE_SERVER='192.168.1.231'
REMOTE_BACKUP_DIR='/var/storage/sagi/sagi-pc-backups'

# SCRIPT ARGUMENTS
# The source and destination paths have to come before the other parameters
localPath="${1-}"
remoteDirName="${2-}"
fullTargetPath="${REMOTE_SERVER}:${REMOTE_BACKUP_DIR}/${remoteDirName}"

# ARGUMENT VALIDATION
validatePathsAreSpecified "${localPath}" "${remoteDirName}"

excludedDirs="$(getExcludedDirsFromArgs "$@")"

# THE BACKUP PROCESS
printBackupMessage "${localPath}" "${fullTargetPath}" "${excludedDirs}"

if ! isReachableTcp "${REMOTE_SERVER}" 22; then
	echo "Failed to connect to '${REMOTE_SERVER}' on port 22. Aborting..." >&2
	exit 1
fi

syncDirs "${localPath}" "${fullTargetPath}" "${excludedDirs}"

# update the remote dir's modification date
# shellcheck disable=SC2029 # Variables are expanded on the client side on purpose
ssh "${REMOTE_SERVER}" "touch '${REMOTE_BACKUP_DIR}/${remoteDirName}'"
