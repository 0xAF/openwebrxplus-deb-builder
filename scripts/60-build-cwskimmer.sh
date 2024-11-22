#!/usr/bin/env bash
set -euo pipefail

# read and export dependencies
# shellcheck disable=SC1091
source /build.env

: "${GIT_CWSKIMMER:=https://github.com/luarvique/csdr-cwskimmer.git}"

if [ "${BUILD_CWSKIMMER:-}" == "y" ]; then
	log suc "Building cwskimmer..."
	git clone -b main "$GIT_CWSKIMMER"
	pushd csdr-cwskimmer
	dpkg-buildpackage -us -uc
	popd

	# copy debs to the output folder
	cp ./*.deb "${OUTPUT_DIR}/"

	# clean
	rm -rf ./*.deb csdr-cwskimmer
fi
