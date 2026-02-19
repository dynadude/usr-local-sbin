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
	excludedDirs=''
	# Use getopts while ignoring positional arguments
	while [ $OPTIND -le "$#" ]; do
		if getopts x: opt; then
			case "${opt}" in
			x)
				excludedDirs+="$OPTARG"$'\n'
				;;
			esac
		else
			((OPTIND++))
		fi
	done

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

function contains() (
	# KEEP IN MIND THAT "list" IS A NEWLINE-SEPARATED STRING
	list="$1"
	string="$2"

	IFS=$'\n'
	for item in ${list}; do
		if [ "${item}" = "${string}" ]; then
			return 0
		fi
	done

	return 1
)

function getAllZfsDatasets() (
	# The "grep" is there to filter out zpools
	zfs list -H -o name | grep /
)
