#!/usr/bin/env bash

# fail script if anything fails
set -e

# GLOBALS
REMOTE_SERVER='192.168.1.231'
REMOTE_BACKUP_DIR='/var/storage/sagi/sagi-pc-backup'

# SCRIPT ARGUMENTS
LOCAL_PATH="$1"
REMOTE_DIR_NAME="$2"

# We need to modify the destination path to include the server name before
# passing manually both paths to local-rsync-backup.sh (the rest of the parameters will be passed automatically, except for -n)
shift
shift

SCRIPT_DIR="$(dirname ${0})"
LOCAL_RSYNC_BACKUP_SCRIPT_PATH="${SCRIPT_DIR}/local-rsync-backup.sh"
FULL_TARGET_PATH="$REMOTE_SERVER:$REMOTE_BACKUP_DIR/$REMOTE_DIR_NAME"

# remote dir name default value
if [ -z "$REMOTE_DIR_NAME" ]; then
	echo 'The remote directory name was not specified. Using the local directory name...'
	[[ "$LOCAL_PATH" =~ .*/(.*)/*$ ]]
	REMOTE_DIR_NAME="${BASH_REMATCH[1]}"
	if [ -z "$REMOTE_DIR_NAME" ]; then
		echo 'Failed at getting the remote directory name from the local directory name. Exiting...' >&2
		exit 3
	fi
fi

# CALLING THE LOCAL RSYNC BACKUP SCRIPT
# There's no need to validate parameters since the local script will do that.
# Pass along all parameters to the local scripts (exclusion dirs)
"${LOCAL_RSYNC_BACKUP_SCRIPT_PATH}" "${LOCAL_PATH}" "${FULL_TARGET_PATH}" -n "$@"

# update the remote dir's modification date
ssh "$REMOTE_SERVER" "touch '$REMOTE_BACKUP_DIR/$REMOTE_DIR_NAME'"
