#!/bin/bash
set -euo pipefail

# read and export dependencies
# shellcheck disable=SC1091
source /build.env

# set default value if not provided
: "${GIT_DIGIHAM:=https://github.com/jketterl/digiham.git}"

if [ "${BUILD_DIGIHAM:-}" == "y" ]; then
	log suc "Building DigiHAM..."
	git clone -b master "$GIT_DIGIHAM"
	pushd digiham
	sed -i 's/set(CMAKE_CXX_STANDARD 11)/set(CMAKE_CXX_STANDARD 17)/' CMakeLists.txt
	dpkg-buildpackage -us -uc
	popd
	# PyDigiHAM build depends on the latest DigiHAM
	sudo dpkg -i *digiham*.deb

	# copy debs to the output folder
	cp ./*.deb "${OUTPUT_DIR}/"
	
	# clean
	rm -rf ./*.deb digiham/
fi

