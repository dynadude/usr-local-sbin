#!/usr/bin/env bash

SCRIPT_DIR="$(realpath "$(dirname "${0}")")"

set -o nounset # abort on unbound variable
set -o pipefail

# START TESTS FOR local-rsync-backup.sh
(
	trap 'rm -rf /tmp/del/' ERR EXIT

	function resetDir() (
		mkdir -p /tmp/del/ /tmp/del/src/ /tmp/del/dest/ || return
		cd /tmp/del/ || return
		rm -rf src/* dest/* || return
		touch src/good src/bad dest/del
	)

	function incorrectData() (
		exitCode="${?}"
		echo 'Incorrect dest dir data after running local-rsync-backup.sh' >&2
		find /tmp/del/dest/
		return "${exitCode}"
	)

	resetDir || exit
	cd /tmp/del/ || exit

	"${SCRIPT_DIR}/local-rsync-backup.sh" &&
		echo 'local-rsync-backup.sh did not crash when it should have' &&
		exit 1
	echo "Passed test 'no params'!"

	resetDir || exit
	"${SCRIPT_DIR}/local-rsync-backup.sh" src/ &&
		echo 'local-rsync-backup.sh did not crash when it should have' &&
		exit 1
	echo "Passed test 'only source dir'!"

	resetDir || exit
	"${SCRIPT_DIR}/local-rsync-backup.sh" src/ dest/ -z gsgsfg &&
		echo 'local-rsync-backup.sh did not crash when it should have' &&
		exit 1
	echo "Passed test 'non-existent param'!"

	resetDir || exit
	"${SCRIPT_DIR}/local-rsync-backup.sh" fake dest &&
		echo 'local-rsync-backup.sh did not crash when it should have' &&
		exit 1
	{ ! [ -f dest/good ] && ! [ -f dest/bad ] && [ -f dest/del ]; } || incorrectData || exit
	echo "Passed test 'regular run with a non-existent source'!"

	resetDir || exit
	"${SCRIPT_DIR}/local-rsync-backup.sh" /tmp/del/src /tmp/del/dest || (
		exitCode="${?}"
		echo 'Failed at running local-rsync-backup.sh' >&2
		exit "${exitCode}"
	) || exit
	{ [ -f dest/good ] && [ -f dest/bad ] && ! [ -f dest/del ]; } || incorrectData || exit
	echo "Passed test 'regular run with no trailing slash in dir names and no exclusions using an absolute path'!"

	resetDir || exit
	"${SCRIPT_DIR}/local-rsync-backup.sh" src/ dest/ -x /bad || (
		exitCode="${?}"
		echo 'Failed at running local-rsync-backup.sh'
		exit "${exitCode}"
	) || exit
	{ [ -f dest/good ] && ! [ -f dest/bad ] && ! [ -f dest/del ]; } || incorrectData || exit
	echo "Passed test 'regular run with an exclusion that starts with a slash'!"

	resetDir || exit
	# Regular run with an exclusion that does not start with a slash
	"${SCRIPT_DIR}/local-rsync-backup.sh" src/ dest/ -x bad || (
		exitCode="${?}"
		echo 'Failed at running local-rsync-backup.sh'
		exit "${exitCode}"
	) || exit
	{ [ -f dest/good ] && ! [ -f dest/bad ] && ! [ -f dest/del ]; } || incorrectData || exit
	echo "Passed test 'regular run with an exclusion that does not start with a slash'!"

	# No src/bad file
	resetDir || exit
	rm src/bad || exit
	"${SCRIPT_DIR}/local-rsync-backup.sh" src/ dest/ -x bad || (
		exitCode="${?}"
		echo 'Failed at running local-rsync-backup.sh'
		exit "${exitCode}"
	) || exit
	{ [ -f dest/good ] && ! [ -f dest/bad ] && ! [ -f dest/del ]; } || incorrectData || exit
	echo "Passed test 'regular run with an exclusion for an item that does not exist'!"
)
# END TESTS FOR local-rsync-backup.sh
