#!/bin/bash
set -euo pipefail

# read and export dependencies
source /build.env

# set default value if not provided
: "${GIT_PYCSDR:=https://github.com/luarvique/pycsdr.git}"

if [ "${BUILD_PYCSDR:-}" == "y" ]; then
	log suc "Building PyCSDR..."
	git clone -b master "$GIT_PYCSDR"
	cd pycsdr
	dpkg-buildpackage -us -uc
	cd /

	# OpenWebRX build depends on the latest PyCSDR
	dpkg -i python3-csdr*.deb

	# copy debs to the output folder
	cp ./*.deb "${OUTPUT_DIR}/"
	
	# clean
	rm -rf ./*.deb pycsdr/
fi

