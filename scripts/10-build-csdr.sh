#!/bin/bash
set -euo pipefail

# read and export dependencies
# shellcheck disable=SC1091
source /build.env

# set default value if not provided
: "${GIT_CSDR:=https://github.com/luarvique/csdr.git}"
	
if [ "${BUILD_CSDR:-}" == "y" ]; then
	log suc "Building CSDR..."
	git clone -b master "$GIT_CSDR"
	cd csdr
	if [ "$(gcc -dumpversion)" -gt 10 ]; then
		# fix armhf builds on gcc>=11 (bookworm)
		sed -i 's/-march=armv7-a /-march=armv7-a+fp /g' CMakeLists.txt
	fi
	dpkg-buildpackage -us -uc
	cd /

	# Install debs, so the next packages can use it.
	# PyCSDR, CSDR-ETI, and OWRX-Connector depend on the latest CSDR
	dpkg -i csdr*.deb libcsdr*.deb nmux*.deb

	# copy debs to the output folder
	cp ./*.deb "${OUTPUT_DIR}/"
	
	# clean
	rm -rf ./*.deb csdr/
fi
