#!/bin/bash
set -euo pipefail

# read and export dependencies
# shellcheck disable=SC1091
source /build.env

# set default value if not provided
: "${GIT_OPENWEBRX:=https://github.com/luarvique/openwebrx.git}"

if [ "${BUILD_OWRX:-}" == "y" ]; then
	log suc "Building OpenWebRX..."
	git clone -b master "$GIT_OPENWEBRX"
	pushd openwebrx
	dpkg-buildpackage -us -uc
	popd
	# Not installing OpenWebRX here since there are no further
	# build steps depending on it
	#sudo dpkg -i openwebrx*.deb

	# copy debs to the output folder
	cp ./*.deb "${OUTPUT_DIR}/"
	
	# clean
	rm -rf ./*.deb SoapySDRPlay3/
fi

