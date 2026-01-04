#!/usr/bin/env bash

# fail script if anything fails
set -e

RSYNC_FILES_VANISHED_EXIT_CODE=24

# SCRIPT ARGUMENTS
# The source and destination paths have to come before the other parameters
SRC_PATH="$1"
DEST_PATH="$2"

# ARGUMENT VALIDATION
if [ -z "$SRC_PATH" ]; then
	echo 'The source dir to back up was not specified. Exiting...' >&2
	exit 1
fi

if [ -z "$DEST_PATH" ]; then
	echo 'The backup destination dir was not specified. Exiting...' >&2
	exit 3
fi

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

# Compression is useful for remote backups, but is useless for local ones.
# It is always enabled here since it does not cause a big enough of an overhead to care.
rsync -i -a --compress-choice=zstd --hard-links --one-file-system --delete --delete-excluded --exclude-from=<(echo "$EXCLUDED_DIRS") "$SRC_PATH/" "$DEST_PATH/" || (
	EXIT_CODE="$?"
	if [ "$EXIT_CODE" = "$RSYNC_FILES_VANISHED_EXIT_CODE" ]; then
		exit 0
	else
		exit "$EXIT_CODE"
	fi
)

# This parameter is used by the remote-backup.sh script
if ! [ "$NO_TOUCH" = 1 ]; then
	# update the destination dir's modification date
	touch "$DEST_PATH"
fi
