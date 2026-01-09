#!/usr/bin/env bash

function isReachable() (
	CONNECTION_ATTEMPTS=5

	host="$1"

	for ((i = 0; i < "${CONNECTION_ATTEMPTS}"; i++)); do
		if ping -c 1 "$host" &>/dev/null; then
			return 0
		fi
	done

	return 1
)

function validatePathsAreSpecified() (
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

function getExcludedDirsFromArgs() (
	# Necessary because getopts doesn't do exclusions correctly otherwise for some reason
	shift
	shift

	excludedDirs=''
	while getopts "x:" opt; do
		case "${opt}" in
		x)
			excludedDirs+="$OPTARG"$'\n'
			;;
		*)
			exit 12
			;;
		esac
	done
	shift $((OPTIND - 1))

	echo "$excludedDirs"
)

function printBackupMessage() (
	sourcePath="$1"
	destinationPath="$2"
	excludedDirs="$3"

	echo "Backing up '$sourcePath' to '$destinationPath'"
	if [ -n "${excludedDirs}" ]; then
		echo 'Excluded Dirs:'
		echo "${excludedDirs}"
	fi
)

function syncDirs() (
	RSYNC_FILES_VANISHED_EXIT_CODE=24

	sourcePath="$1"
	destinationPath="$2"
	excludedDirs="$3"
	sshPort="${4-}"
	if [ -z "$sshPort" ]; then
		sshCommand=()
	else
		sshCommand=(-e "ssh -p $sshPort")
	fi

	# Compression is useful for remote backups, but is useless for local ones.
	# It is always enabled here since it does not cause a big enough of an overhead to care.
	rsync -i -a --compress-choice=zstd --hard-links --one-file-system --delete --delete-excluded "${sshCommand[@]}" --exclude-from=<(echo "$excludedDirs") "${sourcePath}/" "${destinationPath}/" || (
		exitCode="$?"
		if [ "$exitCode" = "$RSYNC_FILES_VANISHED_EXIT_CODE" ]; then
			return 0
		else
			return "$exitCode"
		fi
	)
)
