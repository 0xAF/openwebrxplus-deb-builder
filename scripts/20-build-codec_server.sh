#!/bin/bash
set -euo pipefail

# read and export dependencies
# shellcheck disable=SC1091
source /build.env

apt install -y adduser

# set default value if not provided
: "${GIT_CODECSERVER:=https://github.com/jketterl/codecserver.git}"

if [ "${BUILD_CODECSERVER:-}" == "y" ]; then
	log suc "Building CodecServer..."
	git clone -b master "$GIT_CODECSERVER"
	pushd codecserver
	dpkg-buildpackage -us -uc
	popd
	# Digiham depends on libcodecserver-dev
	dpkg -i libcodecserver_*.deb codecserver_*.deb libcodecserver-dev_*.deb

	# copy debs to the output folder
	cp ./*.deb "${OUTPUT_DIR}/"
	
	# clean
	rm -rf ./*.deb codecserver/
fi

