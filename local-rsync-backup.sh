#!/usr/bin/env bash

# Import functions
SCRIPT_DIR="$(realpath "$(dirname "${0}")")"
. "${SCRIPT_DIR}/backup-utils.sh"

# BASH STRICT MODE
set -o nounset # abort on unbound variable
set -o pipefail

# SCRIPT ARGUMENTS
# The source and destination paths have to come before the other parameters
sourcePath="${1-}"
destinationPath="${2-}"

# ARGUMENT VALIDATION
validatePathsAreSpecified "${sourcePath}" "${destinationPath}" || exit

excludedDirs="$(getExcludedDirsFromArgs "$@")" || (
	exitCode="${?}"
	echo 'Failed at getting the excluded dirs from the command-line arguments' >&2
	exit "${exitCode}"
) || exit

# THE BACKUP PROCESS
printBackupMessage "${sourcePath}" "${destinationPath}" "${excludedDirs}" || exit

syncDirs "${sourcePath}" "${destinationPath}" "${excludedDirs}" || exit

# update the destination dir's modification date
touch "${destinationPath}" || exit
