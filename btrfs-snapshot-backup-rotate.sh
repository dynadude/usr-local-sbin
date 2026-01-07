#!/usr/bin/env bash

# fail script if anything fails
set -e

SRC_PATH="$1"
SNAPSHOT_PREFIX="$2"
BACKUPS_TO_KEEP="$3"

# ARGUMENT VALIDATION
if [ -z "$SRC_PATH" ]; then
	echo 'The source dir to back up was not specified. Exiting...' >&2
	exit 1
fi

if ! [ -d "$SRC_PATH" ]; then
	echo 'The specified source dir to back up does not exist or is not a directory. Exiting...' >&2
	exit 2
fi

# snapshot prefix default value
if [ -z "$SNAPSHOT_PREFIX" ]; then
	echo 'The snapshot prefix was not specified. Using ".backups/"...'
	SNAPSHOT_PREFIX='.backups/'
fi

# backups to keep default value
if [ -z "$BACKUPS_TO_KEEP" ]; then
	echo 'The amount of backups to keep was not specified. Using 30...'
	BACKUPS_TO_KEEP=30
fi

dirsToRemove=$(find "${SRC_PATH}/${SNAPSHOT_PREFIX}"* -maxdepth 0 | head -n -"${BACKUPS_TO_KEEP}")

if [ -n "$dirsToRemove" ]; then
	echo "Removing Backups:"
	echo "$dirsToRemove"
	echo "$dirsToRemove" | xargs btrfs subvolume delete
else
	echo "No Backups to Remove"
fi
