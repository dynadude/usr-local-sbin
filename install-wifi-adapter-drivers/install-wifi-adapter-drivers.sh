#! /usr/bin/env bash

# fail on any error
set -e
set -o pipefail

# START OF CONSTANT SECTION
driverDebPackagePath="$(dirname "$0")/aic8800d80fdrvpackage.deb"

kernelVersion="$(uname -r)"
driverInstallDir="/lib/modules/${kernelVersion}/kernel/drivers/net/wireless/aic8800"
# END OF CONSTANT SECTION

if ! [ -d "${driverInstallDir}" ]; then
	echo "Driver is not installed for the Linux kernel currently in use. Reinstalling driver from ${driverDebPackagePath}..."
	apt reinstall -y "${driverDebPackagePath}"
fi
