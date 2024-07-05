#!/usr/bin/env bash
set -euo pipefail

# read and export dependencies
# shellcheck disable=SC1091
source /build.env

: "${GIT_ACARSDEC:=https://github.com/TLeconte/acarsdec}"

if [ "${BUILD_ACARSDEC:-}" == "y" ]; then
  apt install -y libxml2-dev libjansson-dev

	log suc "Building acarsdec..."
	git clone "$GIT_ACARSDEC"
  pushd acarsdec
    git checkout 7920079b8e005c6c798bd478a513211daf9bbd25
    patch -p1 < /scripts/patches/acarsdec-3.7.patch
    dpkg-buildpackage -b -rfakeroot -us -uc
  popd

	# copy debs to the output folder
	cp ./*.deb "${OUTPUT_DIR}/"
	
	# clean
	rm -rf ./*.deb acarsdec
fi
