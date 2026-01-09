#!/usr/bin/env bash

# Import functions
SCRIPT_DIR="$(dirname ${0})"
. "${SCRIPT_DIR}/backup-utils.sh"

# BASH STRICT MODE
set -o errexit # abort on nonzero exitstatus
set -o nounset # abort on unbound variable
set -o pipefail

# SCRIPT ARGUMENTS
# The source and destination paths have to come before the other parameters
SRC_PATH="${1-}"
DEST_PATH="${2-}"

# ARGUMENT VALIDATION
validatePathsAreSpecified "$SRC_PATH" "$DEST_PATH"

EXCLUDED_DIRS="$(getExcludedDirsFromArgs "$@")"

# THE BACKUP PROCESS
printBackupMessage "$SRC_PATH" "$DEST_PATH" "$EXCLUDED_DIRS"

syncDirs "$SRC_PATH" "$DEST_PATH" "$EXCLUDED_DIRS"

# update the destination dir's modification date
touch "$DEST_PATH"
