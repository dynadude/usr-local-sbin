#!/usr/bin/env bash

function runWithRetries() (
	func="$1"
	maxRetries="$2"
	cooldownSeconds="${3-0}"

	if [ "${maxRetries}" -le 0 ]; then
		echo "runWithRetries: the value for maxRetries must be a positive integer"
	fi

	for ((i = 1; i <= "${maxRetries}"; i++)); do
		"${func}" && return

		exitCode="$?"
		echo "Running '${func}' failed on try ${i} out of ${maxRetries}" >&2

		if [ "${cooldownSeconds}" -gt 0 ]; then
			sleep "${cooldownSeconds}"
		fi
	done

	return "${exitCode}"
)

function isReachableIcmp() (
	host="$1"
	maxRetries="${2-5}"
	timeoutSeconds="${3-1}"
	cooldownSeconds="${4-1}"

	# shellcheck disable=SC2317 # This is called indirectly by runWithRetries
	function pingHost() (
		ping -c 1 -W "${timeoutSeconds}" "${host}" &>/dev/null
	)

	# When the system comes back from suspension, networking needs time to start.
	# For some reason, ping seems to fail instantly if that happens, so sleeping is necessary.
	runWithRetries pingHost "${maxRetries}" "${cooldownSeconds}"
)

function isReachableTcp() (
	host="$1"
	port="$2"
	maxRetries="${3-5}"
	timeoutSeconds="${4-1}"
	cooldownSeconds="${5-1}"

	# shellcheck disable=SC2317 # This is called indirectly by runWithRetries
	function ncHost() (
		nc -z -w "${timeoutSeconds}" "${host}" "${port}" &>/dev/null
	)

	# When the system comes back from suspension, networking needs time to start.
	# A cooldown isn't necessary with netcat as it is with ping, but I keep it for standardisation.
	runWithRetries ncHost "${maxRetries}" "${cooldownSeconds}"
)

function validatePathsAreSpecified() (
	sourcePath="$1"
	destinationPath="$2"

	if [ -z "${sourcePath}" ]; then
		echo 'The source dir to back up was not specified. Exiting...' >&2
		exit 1
	fi

	if [ -z "${destinationPath}" ]; then
		echo 'The backup destination dir was not specified. Exiting...' >&2
		exit 3
	fi
)

function getExcludedDirsFromArgs() (
	excludedDirs=''
	# Use getopts while ignoring positional arguments
	while [ "${OPTIND}" -le "$#" ]; do
		if getopts x: opt; then
			case "${opt}" in
			x)
				excludedDirs+="${OPTARG}"$'\n'
				;;

			*)
				exit 1
				;;
			esac
		else
			((OPTIND++))
		fi
	done

	echo "${excludedDirs}"
)

function printBackupMessage() (
	sourcePath="$1"
	destinationPath="$2"
	excludedDirs="$3"

	echo "Backing up '${sourcePath}' to '${destinationPath}'"
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
	if [ -z "${sshPort}" ]; then
		sshCommand=()
	else
		sshCommand=(-e "ssh -p $sshPort")
	fi

	# Compression is useful for remote backups, but is useless for local ones.
	# It is always enabled here since it does not cause a big enough of an overhead to care.
	rsync -i -a --compress-choice=zstd --hard-links --one-file-system --delete --delete-excluded "${sshCommand[@]}" --exclude-from=<(echo "${excludedDirs}") "${sourcePath}/" "${destinationPath}/" || (
		exitCode="$?"
		if [ "${exitCode}" = "${RSYNC_FILES_VANISHED_EXIT_CODE}" ]; then
			return 0
		else
			return "${exitCode}"
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

function getLatestZfsSnapshot() (
	dataset="$1"

	latestSnapshot="$(zfs list -H -t snapshot -o name "${dataset}" | tail -1)"

	if [ -n "${latestSnapshot}" ]; then
		echo "${latestSnapshot}"
	else
		return 1
	fi
)

function getServiceExitCode() (
	serviceName="$1"

	set +o pipefail
	systemctl show "${serviceName}" | grep '^ExecMainStatus' | grep -oE '[0-9]+'
)
