#!/usr/bin/env bash

# fail script if anything fails
set -e

# GLOBALS
REMOTE_SERVER='192.168.1.231'
REMOTE_BACKUP_DIR='/var/storage/sagi/sagi-pc-backup'

# SCRIPT ARGUMENTS
LOCAL_PATH="$1"
REMOTE_DIR_NAME="$2"

shift
shift

EXCLUDED_DIRS=''
while getopts "x:" opt; do
	case "${opt}" in
		x)
			EXCLUDED_DIRS+="$OPTARG"$'\n'
			;;
		*)
			# no idea why it's 12
			exit 12
			;;
	esac
done
shift $((OPTIND-1))


# ARGUMENT VALIDATION
if [ -z "$LOCAL_PATH" ] ; then
	echo 'The local dir to back up was not specified. Exiting...' >&2
	exit 1
fi

if ! [ -d "$LOCAL_PATH" ] ; then
	echo 'The specified local dir to back up does not exist or is not a directory. Exiting...' >&2
	exit 2
fi

# remote dir name default value
if [ -z "$REMOTE_DIR_NAME" ] ; then
	echo 'The remote directory name was not specified. Using the local directory name...'
	[[ "$LOCAL_PATH" =~ .*/(.*)/*$ ]]
	REMOTE_DIR_NAME="${BASH_REMATCH[1]}"
	if [ -z "$REMOTE_DIR_NAME" ] ; then
		echo 'Failed at getting the remote directory name from the local directory name. Exiting...' >&2
		exit 3
	fi
fi


# THE BACKUP PROCESS
TARGET_DIR="$REMOTE_SERVER:$REMOTE_BACKUP_DIR/$REMOTE_DIR_NAME"
echo "Backing up '$LOCAL_PATH' to '$TARGET_DIR'"
if [ -n "${EXCLUDED_DIRS}" ]; then
	echo 'Excluded Dirs:'
	echo "${EXCLUDED_DIRS}"
fi

(rsync -i -a --compress-choice=zstd --hard-links --one-file-system --delete --delete-excluded --exclude-from=<(echo "$EXCLUDED_DIRS") "$LOCAL_PATH/" "${TARGET_DIR}/" || exit 0)

# update the remote dir's modification date
ssh "$REMOTE_SERVER" "touch '$REMOTE_BACKUP_DIR/$REMOTE_DIR_NAME'"

