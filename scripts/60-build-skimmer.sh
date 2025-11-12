#!/usr/bin/env bash
set -euo pipefail

# read and export dependencies
# shellcheck disable=SC1091
source /build.env

: "${GIT_SKIMMER:=https://github.com/luarvique/csdr-skimmer.git}"

if [ "${BUILD_SKIMMER:-}" == "y" ]; then
	log suc "Building skimmer..."
	git clone -b main "$GIT_SKIMMER"
	pushd csdr-skimmer
	dpkg-buildpackage -us -uc
	popd

	# copy debs to the output folder
	cp ./*.deb "${OUTPUT_DIR}/"

	# clean
	rm -rf ./*.deb csdr-skimmer
fi
