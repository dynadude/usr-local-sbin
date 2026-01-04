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

shift
shift

EXCLUDED_DIRS=''
while getopts "x:n" opt; do
	case "${opt}" in
	x)
		EXCLUDED_DIRS+="$OPTARG"$'\n'
		;;
	n)
		NO_TOUCH=1
		;;
	*)
		exit 12
		;;
	esac
done
shift $((OPTIND - 1))

# THE BACKUP PROCESS
echo "Backing up '$SRC_PATH' to '$DEST_PATH'"
if [ -n "${EXCLUDED_DIRS}" ]; then
	echo 'Excluded Dirs:'
	echo "${EXCLUDED_DIRS}"
fi

syncDirs "$SRC_PATH" "$DEST_PATH" "$EXCLUDED_DIRS"

# This parameter is used by the remote-backup.sh script
if ! [ "$NO_TOUCH" = 1 ]; then
	# update the destination dir's modification date
	touch "$DEST_PATH"
fi
