#!/usr/bin/env bash
set -euo pipefail

# read and export dependencies
# shellcheck disable=SC1091
source /build.env

: "${GIT_DUMP1090:=https://github.com/openwebrx/dump1090-debian}"

if [ "${BUILD_DUMP1090:-}" == "y" ]; then
	apt install -y \
		libboost-system-dev \
		libboost-program-options-dev \
		libboost-regex-dev \
		libboost-filesystem-dev \
		libsoapysdr-dev \
		libbladerf-dev libhackrf-dev liblimesuite-dev libncurses5-dev
	log suc "Building dump1090..."
	git clone -b debian/bullseye "$GIT_DUMP1090"

	pushd dump1090-debian

	if grep -q " -Wno-error=calloc-transposed-args" Makefile; then
		:
	elif grep -q "^DUMP1090_CFLAGS := " Makefile; then
		sed -i '0,/^DUMP1090_CFLAGS := /s//&-Wno-error=calloc-transposed-args /' Makefile
	else
		log err "target line not found"
		exit 1
	fi

	popd

	tar czf dump1090-fa_8.2.orig.tar.gz dump1090-debian/

	pushd dump1090-debian
	#dpkg-buildpackage -us -uc -Pcustom,rtlsdr,hackrf,limesdr
	dpkg-buildpackage -us -uc
	popd

	# copy debs to the output folder
	cp ./*.deb "${OUTPUT_DIR}/"

	# clean
	rm -rf ./*.deb dump1090-debian dump1090-fa_8.2.orig.tar.gz
fi
