#!/usr/bin/env bash
set -euo pipefail

# read and export dependencies
# shellcheck disable=SC1091
source /build.env

: "${GIT_DUMPHFDL:=https://github.com/szpajder/dumphfdl}"

if [ "${BUILD_DUMPHFDL:-}" == "y" ]; then
	# apt install -y libacars-dev libconfig++-dev
	apt install -y libconfig++-dev
	log suc "Building dumphfdl..."
	git clone "$GIT_DUMPHFDL"
	
	cd dumphfdl
	USER=root dh_make --createorig -s -y -p dumphfdl_$(grep Version CHANGELOG.md | head -1 | awk '{ print $3 }')

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
	rm -rf ./*.deb dumphfdl*
fi
