#!/usr/bin/env bash

# fail script if anything fails
set -e

RSYNC_FILES_VANISHED_EXIT_CODE=24

# SCRIPT ARGUMENTS
SRC_PATH="$1"
DEST_PATH="$2"

shift
shift

EXCLUDED_DIRS=''
while getopts "x:" opt; do
	case "${opt}" in
		x)
			EXCLUDED_DIRS+="$OPTARG"$'\n'
			;;
		*)
			exit 12
			;;
	esac
done
shift $((OPTIND-1))


# ARGUMENT VALIDATION
if [ -z "$SRC_PATH" ] ; then
	echo 'The source dir to back up was not specified. Exiting...' >&2
	exit 1
fi

if ! [ -d "$SRC_PATH" ] ; then
	echo 'The specified source dir to back up does not exist or is not a directory. Exiting...' >&2
	exit 2
fi

if [ -z "$DEST_PATH" ] ; then
	echo 'The specified destination dir to back up does not exist or is not a directory. Exiting...' >&2
	exit 3
fi


# THE BACKUP PROCESS
echo "Backing up '$SRC_PATH' to '$DEST_PATH'"
if [ -n "${EXCLUDED_DIRS}" ]; then
	echo 'Excluded Dirs:'
	echo "${EXCLUDED_DIRS}"
fi

rsync -i -a --hard-links --one-file-system --delete --delete-excluded --exclude-from=<(echo "$EXCLUDED_DIRS") "$SRC_PATH/" "$DEST_PATH/" || (EXIT_CODE="$?" ; if [ "$EXIT_CODE" = "$RSYNC_FILES_VANISHED_EXIT_CODE" ] ; then exit 0 ; else exit "$EXIT_CODE" ; fi)

# update the destination dir's modification date
touch "$DEST_PATH"

