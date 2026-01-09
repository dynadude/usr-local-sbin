#!/usr/bin/env bash

# Import functions
SCRIPT_DIR="$(dirname "${0}")"
. "${SCRIPT_DIR}/backup-utils.sh"

# BASH STRICT MODE
set -o errexit # abort on nonzero exitstatus
set -o nounset # abort on unbound variable
set -o pipefail

# SCRIPT ARGUMENTS
# The source and destination paths have to come before the other parameters
sourcePath="${1-}"
destinationPath="${2-}"

# ARGUMENT VALIDATION
validatePathsAreSpecified "${sourcePath}" "${destinationPath}"

excludedDirs="$(getExcludedDirsFromArgs "$@")"

# THE BACKUP PROCESS
printBackupMessage "${sourcePath}" "${destinationPath}" "${excludedDirs}"

syncDirs "${sourcePath}" "${destinationPath}" "${excludedDirs}"

# update the destination dir's modification date
touch "${destinationPath}"
