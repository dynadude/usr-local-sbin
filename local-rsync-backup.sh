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
validatePathsAreSpecified "$SRC_PATH" "$DEST_PATH"

EXCLUDED_DIRS="$(getExcludedDirsFromArgs "$@")"

# THE BACKUP PROCESS
printBackupMessage "$SRC_PATH" "$DEST_PATH" "$EXCLUDED_DIRS"

syncDirs "$SRC_PATH" "$DEST_PATH" "$EXCLUDED_DIRS"

# update the destination dir's modification date
touch "$DEST_PATH"
