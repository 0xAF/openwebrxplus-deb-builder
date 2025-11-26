#!/usr/bin/env bash
set -euo pipefail

# read and export dependencies
# shellcheck disable=SC1091
source /build.env

: "${GIT_APRS_SYMBOLS:=https://github.com/jketterl/aprs-symbols-debian}"

if [ "${BUILD_APRS_SYMBOLS:-}" == "y" ]; then
	log suc "Building aprs-symbols..."
	git clone -b debian/bullseye "$GIT_APRS_SYMBOLS"

	tar czf aprs-symbols_0.0.1.orig.tar.gz aprs-symbols-debian/
	pushd aprs-symbols-debian

	dpkg-buildpackage -us -uc
	popd

	# copy debs to the output folder
	cp ./*.deb "${OUTPUT_DIR}/"

	# clean
	rm -rf ./*.deb aprs-symbols-debian aprs-symbols_0.0.1.orig.tar.gz
fi
