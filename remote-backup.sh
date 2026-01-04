#!/usr/bin/env bash

# Import functions
SCRIPT_DIR="$(dirname ${0})"
. "${SCRIPT_DIR}/backup-utils.sh"

# fail script if anything fails
set -e

# GLOBALS
REMOTE_SERVER='192.168.1.231'
REMOTE_BACKUP_DIR='/var/storage/sagi/sagi-pc-backup'

# SCRIPT ARGUMENTS
# The source and destination paths have to come before the other parameters
LOCAL_PATH="$1"
REMOTE_DIR_NAME="$2"
FULL_TARGET_PATH="$REMOTE_SERVER:$REMOTE_BACKUP_DIR/$REMOTE_DIR_NAME"

# ARGUMENT VALIDATION
validatePathsAreSpecified "$LOCAL_PATH" "$REMOTE_DIR_NAME"

EXCLUDED_DIRS="$(getExcludedDirsFromArgs "$@")"

# THE BACKUP PROCESS
printBackupMessage "$LOCAL_PATH" "$FULL_TARGET_PATH" "$EXCLUDED_DIRS"

syncDirs "$LOCAL_PATH" "$FULL_TARGET_PATH" "$EXCLUDED_DIRS"

# update the remote dir's modification date
ssh "$REMOTE_SERVER" "touch '$REMOTE_BACKUP_DIR/$REMOTE_DIR_NAME'"
