#!/usr/bin/env bash
set -euo pipefail

# read and export dependencies
# shellcheck disable=SC1091
source /build.env

: "${GIT_DUMPVDL2:=https://github.com/openwebrx/dumpvdl2-debian}"

if [ "${BUILD_DUMPVDL2:-}" == "y" ]; then
	# apt install -y \
		# libacars-dev libconfig++-dev
	log suc "Building dumpvdl2..."
	git clone -b debian/bullseye "$GIT_DUMPVDL2"

	cd dumpvdl2-debian
	cat >> debian/rules << __EOF__
override_dh_shlibdeps:
	dh_shlibdeps --dpkg-shlibdeps-params=--ignore-missing-info
__EOF__
	cd ..

	tar czf dumpvdl2_2.3.0.orig.tar.gz dumpvdl2-debian/
	pushd dumpvdl2-debian
	dpkg-buildpackage -us -uc
	popd

	# copy debs to the output folder
	cp ./*.deb "${OUTPUT_DIR}/"

	# clean
	rm -rf ./*.deb dumpvdl2-debian
fi
