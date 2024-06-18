#!/bin/bash
set -euo pipefail

# read and export dependencies
# shellcheck disable=SC1091
source /build.env

# set default value if not provided
: "${GIT_OWRXCONNECTOR:=https://github.com/luarvique/owrx_connector.git}"

if [ "${BUILD_OWRXCONNECTOR:-}" == "y" ]; then
	log suc "Building OWRX-Connector..."
	git clone -b master "$GIT_OWRXCONNECTOR"
	cd owrx_connector
	dpkg-buildpackage -us -uc
	cd /
	# Not installing OWRX-Connectors here since there are no
	# further build steps depending on it
	#dpkg -i *connector*.deb

	# copy debs to the output folder
	cp ./*.deb "${OUTPUT_DIR}/"
	
	# clean
	rm -rf ./*.deb owrx_connector/
fi
