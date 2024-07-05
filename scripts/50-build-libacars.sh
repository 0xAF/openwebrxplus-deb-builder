#!/usr/bin/env bash
set -euo pipefail

# read and export dependencies
# shellcheck disable=SC1091
source /build.env

: "${GIT_LIBACARS:=https://github.com/szpajder/libacars}"

if [ "${BUILD_LIBACARS:-}" == "y" ]; then
  apt install -y libxml2-dev libjansson-dev
  log suc "Building libacars..."

  git clone "$GIT_LIBACARS"
	pushd libacars
    git checkout 3147aa0857b6d0fb8989b27445ce46278cb4bae8
    patch -p1 < /scripts/patches/libacars-2.2.0-4.patch
    dpkg-buildpackage -b -rfakeroot -us -uc
	popd

	# Install debs, so the next packages can use it.
	dpkg -i libacars*.deb

	# copy debs to the output folder
	cp ./*.deb "${OUTPUT_DIR}/"

	# clean
	rm -rf ./*.deb libacars
fi
