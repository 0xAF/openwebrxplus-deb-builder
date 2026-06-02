#!/bin/bash
set -euo pipefail

# read and export dependencies
# shellcheck disable=SC1091
source /build.env

# set default value if not provided
: "${GIT_MULTIMON_NG:=https://github.com/luarvique/multimon-ng}"

if [ "${BUILD_MULTIMON_NG:-}" == "y" ]; then
	log suc "Building Multimon-NG..."
	git clone -b master "$GIT_MULTIMON_NG"
	pushd multimon-ng
	dpkg-buildpackage -b -us -uc -j"$(nproc --ignore=4)"
	popd

	# copy debs to the output folder
	cp ./*.deb "${OUTPUT_DIR}/"
	
	# clean
	rm -rf ./*.deb multimon-ng/
fi

