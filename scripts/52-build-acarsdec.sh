#!/usr/bin/env bash
set -euo pipefail

# read and export dependencies
# shellcheck disable=SC1091
source /build.env

: "${GIT_ACARSDEC:=https://github.com/openwebrx/acarsdec-debian}"

if [ "${BUILD_ACARSDEC:-}" == "y" ]; then
  apt install -y libxml2-dev libjansson-dev

	log suc "Building acarsdec..."
	git clone -b debian/bullseye "$GIT_ACARSDEC"
  pushd acarsdec-debian
    # for some reason while dpkg-buildpackage is running the cmake, the cmake cannot find libsndfile.so
    # if i run cmake by hand it is ok, but if it's ran by dpkg-buildpackage, there's the problem.
    # this forces cmake to link to libsndfile without checking if it's available
    sed -i 's/find_library(LIBSNDFILE/set(LIBSNDFILE/' CMakeLists.txt

    gbp dch --debian-branch=debian/bullseye --snapshot --auto
    git add debian/changelog
    git commit -a -m "snapshot changelog"
    gbp buildpackage --git-debian-branch=debian/bullseye -us -uc --git-ignore-new || true # this can be removed once the problem above is fixed
    EDITOR=/bin/true dpkg-source --commit . patch # this can be removed once the problem above is fixed
    gbp buildpackage --git-debian-branch=debian/bullseye -us -uc --git-ignore-new
  popd

	# copy debs to the output folder
	cp ./*.deb "${OUTPUT_DIR}/"
	
	# clean
	rm -rf ./*.deb acarsdec-debian
fi
