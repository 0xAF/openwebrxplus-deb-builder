#!/bin/bash
set -euo pipefail

# read and export dependencies
# shellcheck disable=SC1091
source /build.env

# set default value if not provided
: "${GIT_CSDR_ETI:=https://github.com/luarvique/csdr-eti.git}"

if [ "${BUILD_CSDR_ETI:-}" == "y" ]; then
	log suc "Building CSDR-ETI..."
	git clone "$GIT_CSDR_ETI"
	pushd csdr-eti
	dpkg-buildpackage -us -uc
	popd
	# PyCSDR-ETI build depends on the latest CSDR-ETI
	sudo dpkg -i libcsdr-eti*.deb

	# copy debs to the output folder
	cp ./*.deb "${OUTPUT_DIR}/"
	
	# clean
	rm -rf ./*.deb csdr-eti/
fi
