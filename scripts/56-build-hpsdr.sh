#!/usr/bin/env bash
set -euo pipefail

# read and export dependencies
# shellcheck disable=SC1091
source /build.env

: "${GIT_HPSDR:=https://github.com/openwebrx/hpsdrconnector-debian}"

if [ "${BUILD_HPSDR:-}" == "y" ]; then
	# apt install -y \
		# libacars-dev libconfig++-dev
	log suc "Building hpsdr..."
	git clone -b debian/bullseye "$GIT_HPSDR"

# 	cd hpsdrconnector-debian
# 	cat >> debian/rules << __EOF__
# override_dh_shlibdeps:
# 	dh_shlibdeps --dpkg-shlibdeps-params=--ignore-missing-info
# __EOF__
# 	cd ..

	tar czf hpsdrconnector_0.6.1.orig.tar.gz hpsdrconnector-debian/
	pushd hpsdrconnector-debian
	dpkg-buildpackage -us -uc
	popd

	# copy debs to the output folder
	cp ./*.deb "${OUTPUT_DIR}/"

	# clean
	rm -rf ./*.deb hpsdrconnector-debian
fi
