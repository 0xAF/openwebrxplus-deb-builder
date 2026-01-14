#!/usr/bin/env bash
set -euo pipefail

# read and export dependencies
# shellcheck disable=SC1091
source /build.env

: "${GIT_DUMPVDL2:=https://github.com/szpajder/dumpvdl2}"

# grep Version doc/NEWS.md | head -1 | awk '{ print $3 }'
# USER=root dh_make --createorig -s -y -p dumpvdl2_$(grep Version doc/NEWS.md | head -1 | awk '{ print $3 }')

if [ "${BUILD_DUMPVDL2:-}" == "y" ]; then
	# apt install -y \
		# libacars-dev libconfig++-dev
	log suc "Building dumpvdl2..."
	git clone "$GIT_DUMPVDL2"

	cd dumpvdl2
	USER=root dh_make --createorig -s -y -p dumpvdl2_$(grep Version doc/NEWS.md | head -1 | awk '{ print $3 }')

	gbp dch --snapshot --snapshot-number="$(date +%Y%m%d%H%M%S)" --auto --ignore-branch

# 	cat >> debian/rules << __EOF__
#override_dh_shlibdeps:
#	dh_shlibdeps --dpkg-shlibdeps-params=--ignore-missing-info
#__EOF__

	gbp buildpackage --no-sign --git-ignore-new

	cd ..

	# copy debs to the output folder
	cp ./*.deb "${OUTPUT_DIR}/"

	# clean
	rm -rf ./*.deb dumpvdl2*
fi
