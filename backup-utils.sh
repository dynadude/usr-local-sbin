#!/usr/bin/env bash

function validatePathsSpecified() (
	sourcePath="$1"
	destinationPath="$2"

	if [ -z "$sourcePath" ]; then
		echo 'The source dir to back up was not specified. Exiting...' >&2
		exit 1
	fi

	if [ -z "$destinationPath" ]; then
		echo 'The backup destination dir was not specified. Exiting...' >&2
		exit 3
	fi
)

function syncDirs() (
	RSYNC_FILES_VANISHED_EXIT_CODE=24

	sourcePath="$1"
	destinationPath="$2"
	excludedDirs="$3"

	# Compression is useful for remote backups, but is useless for local ones.
	# It is always enabled here since it does not cause a big enough of an overhead to care.
	rsync -i -a --compress-choice=zstd --hard-links --one-file-system --delete --delete-excluded --exclude-from=<(echo "$excludedDirs") "${sourcePath}/" "${destinationPath}/" || (
		exitCode="$?"
		if [ "$exitCode" = "$RSYNC_FILES_VANISHED_EXIT_CODE" ]; then
			return 0
		else
			return "$exitCode"
		fi
	)
)

