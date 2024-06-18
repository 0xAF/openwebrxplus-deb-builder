#!/usr/bin/env bash
set -euo pipefail

# read and export dependencies
# shellcheck disable=SC1091
source /build.env

: "${GIT_LIBACARS:=https://github.com/openwebrx/libacars-debian}"

if [ "${BUILD_LIBACARS:-}" == "y" ]; then
  apt install -y libxml2-dev libjansson-dev

	log suc "Building libacars..."
	git clone -b debian/bullseye "$GIT_LIBACARS"
  pushd libacars-debian
    gbp dch --debian-branch=debian/bullseye --snapshot --auto
    git add debian/changelog
    git commit -m "snapshot changelog"
    gbp buildpackage --git-debian-branch=debian/bullseye -us -uc
  popd

	# Install debs, so the next packages can use it.
	dpkg -i libacars*.deb

	# copy debs to the output folder
	cp ./*.deb "${OUTPUT_DIR}/"
	
	# clean
	rm -rf ./*.deb libacars-debian
fi
