#!/usr/bin/env bash
set -euo pipefail

# read and export dependencies
# shellcheck disable=SC1091
source /build.env

: "${GIT_DUMP978:=https://github.com/flightaware/dump978}"

if [ "${BUILD_DUMP978:-}" == "y" ]; then
	apt install -y \
		libboost-system-dev \
		libboost-program-options-dev \
		libboost-regex-dev \
		libboost-filesystem-dev \
		libsoapysdr-dev
	log suc "Building dump978..."
	git clone -b master "$GIT_DUMP978"

	pushd dump978
	dpkg-buildpackage -us -uc
	popd

	# copy debs to the output folder
	cp ./*.deb "${OUTPUT_DIR}/"

	# clean
	rm -rf ./*.deb dump978
fi
