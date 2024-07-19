#!/usr/bin/env bash
set -euo pipefail

# read and export dependencies
# shellcheck disable=SC1091
source /build.env

: "${GIT_NRSC5:=https://github.com/luarvique/nrsc5}"

if [ "${BUILD_NRSC5:-}" == "y" ]; then
	apt install -y libao-dev libfftw3-dev

	log suc "Building nrsc5..."
	git clone "$GIT_NRSC5"
	pushd nrsc5
	dpkg-buildpackage -b -rfakeroot -us -uc
	popd

	# copy debs to the output folder
	cp ./*.deb "${OUTPUT_DIR}/"

	# clean
	rm -rf ./*.deb nrsc5
fi
