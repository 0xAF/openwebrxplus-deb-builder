#!/usr/bin/env bash
set -euo pipefail

# read and export dependencies
# shellcheck disable=SC1091
source /build.env

: "${GIT_RADAE:=https://github.com/peterbmarks/radae_decoder}"

if [ "${BUILD_RADAE:-}" == "y" ]; then
	log suc "Building radae..."
	git clone -b main "$GIT_RADAE"
	pushd radae_decoder
	arch="$(dpkg --print-architecture)"
	if [ -f cmake/BuildOpus.cmake ]; then
		log inf "Forcing Opus build parallelism to 6 jobs"
		sed -i -E 's/(BUILD_COMMAND[[:space:]]+)make$/\1make -j6/' cmake/BuildOpus.cmake
		if [ "${arch}" = "arm64" ]; then
			log inf "Applying generic ARMv8 flags for Opus build on arm64"
			sed -i 's/\\ -mno-dotprod//g' cmake/BuildOpus.cmake
			sed -i -E 's/CFLAGS=[^ )]+(\\ [^ )]+)*/CFLAGS=-march=armv8-a\\ -O2/' cmake/BuildOpus.cmake
			log inf "Disabling Opus intrinsics on arm64 for Bookworm compatibility"
			if ! grep -q -- '--disable-intrinsics' cmake/BuildOpus.cmake; then
				sed -i 's@./configure @./configure --disable-intrinsics @' cmake/BuildOpus.cmake
			fi
		elif [ "${arch}" = "armhf" ]; then
			log inf "Applying generic ARMv7 flags for Opus build on armhf"
			sed -i 's/CFLAGS=-march=native\\ -O2/CFLAGS=-march=armv7-a+fp\\ -mfloat-abi=hard\\ -O2/' cmake/BuildOpus.cmake
			log inf "Disabling Opus RTCD on armhf to avoid DNN_COMPUTE_LINEAR_IMPL link issues"
			if ! grep -q -- '--disable-rtcd' cmake/BuildOpus.cmake; then
				sed -i 's@./configure @./configure --disable-rtcd @' cmake/BuildOpus.cmake
			fi
			log inf "Disabling Opus asm/intrinsics on armhf for broad compiler compatibility"
			if ! grep -q -- '--disable-asm' cmake/BuildOpus.cmake; then
				sed -i 's@./configure @./configure --disable-asm @' cmake/BuildOpus.cmake
			fi
			if ! grep -q -- '--disable-intrinsics' cmake/BuildOpus.cmake; then
				sed -i 's@./configure @./configure --disable-intrinsics @' cmake/BuildOpus.cmake
			fi
		fi
	fi
	dpkg-buildpackage -us -uc -j"$(nproc --ignore=4)" -Ppkg.minimal
	popd

	# copy debs to the output folder
	cp ./*.deb "${OUTPUT_DIR}/"

	# clean
	rm -rf ./*.deb radae_decoder
fi
