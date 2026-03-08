#!/bin/bash
set -euo pipefail

# read and export dependencies
# shellcheck disable=SC1091
source /build.env

# set default value if not provided
: "${GIT_PYCSDR_ETI:=https://github.com/luarvique/pycsdr-eti.git}"

if [ "${BUILD_PYCSDR_ETI:-}" == "y" ]; then
	log suc "Building PyCSDR-ETI..."
	git clone "$GIT_PYCSDR_ETI"
	pushd pycsdr-eti
	dpkg-buildpackage -b -us -uc -j"$(nproc --ignore=4)"
	popd
	# Not installing PyCSDR-ETI here since there are no further
	# build steps depending on it
	#dpkg -i python3-csdr-eti*.deb

	# copy debs to the output folder
	cp ./*.deb "${OUTPUT_DIR}/"
	
	# clean
	rm -rf ./*.deb pycsdr-eti/
fi

