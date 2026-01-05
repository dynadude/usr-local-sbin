#!/usr/bin/env bash

# Import functions
SCRIPT_DIR="$(dirname ${0})"
. "${SCRIPT_DIR}/backup-utils.sh"

# fail script if anything fails
set -e

function getPhoneHost() (
	PHONE_WIFI_HOST='sagi-phone'
	PHONE_HOTSPOT_HOST='10.42.0.115'

	for host in "$PHONE_WIFI_HOST" "$PHONE_HOTSPOT_HOST"; do
		if isReachable "$host"; then
			echo "$host"
			return 0
		fi
	done

	return 1
)

# GLOBALS
REMOTE_USER='u0_a293'
REMOTE_SERVER="$REMOTE_USER@$(getPhoneHost)"
SSH_PORT=8022

# SCRIPT ARGUMENTS
# The source and destination paths have to come before the other parameters
REMOTE_PATH="$1"
LOCAL_PATH="/home/sagi/phone-backups/sagi"
FULL_REMOTE_PATH="$REMOTE_SERVER:$REMOTE_PATH"

# ARGUMENT VALIDATION
# The local path isn't specified by the user, but checking it is easier than rewriting the function
validatePathsAreSpecified "$REMOTE_PATH" "$LOCAL_PATH"

EXCLUDED_DIRS="$(getExcludedDirsFromArgs "$@")"

# THE BACKUP PROCESS
printBackupMessage "$FULL_REMOTE_PATH" "$LOCAL_PATH" "$EXCLUDED_DIRS"

syncDirs "$FULL_REMOTE_PATH" "$LOCAL_PATH" "$EXCLUDED_DIRS" "$SSH_PORT"

# update the destination dir's modification date
touch "$LOCAL_PATH"
