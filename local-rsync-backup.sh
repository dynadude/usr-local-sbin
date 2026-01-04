#!/usr/bin/env bash

# Import functions
. ./backup-utils.sh

# fail script if anything fails
set -e

# SCRIPT ARGUMENTS
# The source and destination paths have to come before the other parameters
SRC_PATH="$1"
DEST_PATH="$2"

# ARGUMENT VALIDATION
validatePathsSpecified "$SRC_PATH" "$DEST_PATH"

EXCLUDED_DIRS="$(getExcludedDirsFromArgs "$@")"

# THE BACKUP PROCESS
echo "Backing up '$SRC_PATH' to '$DEST_PATH'"
if [ -n "${EXCLUDED_DIRS}" ]; then
	echo 'Excluded Dirs:'
	echo "${EXCLUDED_DIRS}"
fi

syncDirs "$SRC_PATH" "$DEST_PATH" "$EXCLUDED_DIRS"

# update the destination dir's modification date
touch "$DEST_PATH"
