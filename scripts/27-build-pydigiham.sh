#!/bin/bash
set -euo pipefail

# read and export dependencies
# shellcheck disable=SC1091
source /build.env

# set default value if not provided
: "${GIT_PYDIGIHAM:=https://github.com/jketterl/pydigiham.git}"

if [ "${BUILD_PYDIGIHAM:-}" == "y" ]; then
	log suc "Building PyDigiHAM..."
	git clone -b master "$GIT_PYDIGIHAM"
	pushd pydigiham
	dpkg-buildpackage -us -uc
	popd
	# Not installing PyDigiHAM here since there are no further
	# build steps depending on it
	#dpkg -i python3-digiham*.deb

	# copy debs to the output folder
	cp ./*.deb "${OUTPUT_DIR}/"
	
	# clean
	rm -rf ./*.deb pydigiham/
fi

