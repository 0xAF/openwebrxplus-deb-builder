#!/bin/bash
set -euo pipefail

# read and export dependencies
source /build.env

# set default value if not provided
: "${GIT_REDSEA:=https://github.com/luarvique/redsea.git}"

if [ "${BUILD_REDSEA:-}" == "y" ]; then
	log suc "Building Redsea..."
	git clone -b master "$GIT_REDSEA"
	pushd redsea
	dpkg-buildpackage -us -uc
	popd
	# Not installing Redsea here since there are no further
	# build steps depending on it
	#dpkg -i *redsea*.deb

	# copy debs to the output folder
	cp ./*.deb "${OUTPUT_DIR}/"
	
	# clean
	rm -rf ./*.deb redsea/
fi

