#!/usr/bin/env bash

# Import functions
SCRIPT_DIR="$(dirname "${0}")"
. "${SCRIPT_DIR}/backup-utils.sh"

# BASH STRICT MODE
set -o errexit # abort on nonzero exitstatus
set -o nounset # abort on unbound variable
set -o pipefail

function getPhoneHost() (
	PHONE_WIFI_HOST='sagi-phone'
	PHONE_HOTSPOT_HOST='10.42.0.115'

	for host in "${PHONE_WIFI_HOST}" "${PHONE_HOTSPOT_HOST}"; do
		if isReachableIcmp "${host}"; then
			echo "${host}"
			return 0
		fi
	done

	return 1
)

# GLOBALS
REMOTE_USER='u0_a293'
REMOTE_SERVER="${REMOTE_USER}@$(getPhoneHost)" || (
	echo 'Phone unreachable!' >&2
	exit 1
)
SSH_PORT=8022

# SCRIPT ARGUMENTS
# The source and destination paths have to come before the other parameters
remotePath="${1-}"
LOCAL_PATH="/home/sagi/phone-backups/sagi"
fullRemotePath="${REMOTE_SERVER}:${remotePath}"

# ARGUMENT VALIDATION
# The local path isn't specified by the user, but checking it is easier than rewriting the function
validatePathsAreSpecified "${remotePath}" "${LOCAL_PATH}"

excludedDirs="$(getExcludedDirsFromArgs "$@")"

# THE BACKUP PROCESS
printBackupMessage "${fullRemotePath}" "${LOCAL_PATH}" "${excludedDirs}"

syncDirs "${fullRemotePath}" "${LOCAL_PATH}" "${excludedDirs}" "${SSH_PORT}"

# update the destination dir's modification date
touch "${LOCAL_PATH}"
