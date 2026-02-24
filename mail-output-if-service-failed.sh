#!/usr/bin/env bash

# Import functions
SCRIPT_DIR="$(realpath "$(dirname "${0}")")"
. "${SCRIPT_DIR}/backup-utils.sh"

# BASH STRICT MODE
set -o nounset # abort on unbound variable
set -o pipefail

function getOutputOfLastRunOfService() (
	serviceName="${1}"

	invocationId="$(systemctl show -p InvocationID --value "${serviceName}")" || return 1
	if [ -z "${invocationId}" ]; then
		return 1
	fi

	journalctl _SYSTEMD_INVOCATION_ID="${invocationId}"
)

serviceName="${1}"
emailAddress="${2-sagi.gam.11@gmail.com}"

if [ "$(getServiceExitCode "${serviceName}")" -ne 0 ]; then
	mailContent=$(
		cat <<-EOF
			Subject: Service '${serviceName}' Failed on '${HOSTNAME}'

			$(getOutputOfLastRunOfService "${serviceName}" || (
				echo "Failed at getting the logs of the last run of '${serviceName}'. Aborting..."
				exit 1
			))
		EOF
	)

	echo "Service '${serviceName}' failed. Attempting to send mail..."
	echo "${mailContent}" | sendmail "${emailAddress}"
else
	echo "The last run of '${serviceName}' was successful. Not sending mail..."
fi
