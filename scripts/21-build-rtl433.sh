#!/bin/bash
set -euo pipefail

# read and export dependencies
# shellcheck disable=SC1091
source /build.env

# set default value if not provided
: "${GIT_RTL433:=https://salsa.debian.org/debian-hamradio-team/rtl-433}"

if [ "${BUILD_RTL433:-}" == "y" ]; then
	log suc "Building RTL-433..."
	apt update
	apt install -y doxygen pkgconf
	git clone -b master "$GIT_RTL433"
	pushd rtl-433
	dpkg-buildpackage -b -us -uc
	# gbp buildpackage --git-ignore-branch -us -uc
	popd

	# copy debs to the output folder
	cp ./*.deb "${OUTPUT_DIR}/"
	
	# clean
	rm -rf ./*.deb rtl-433
fi

