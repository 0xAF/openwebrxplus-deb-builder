#!/usr/bin/env bash
set -euo pipefail

# read and export dependencies
# shellcheck disable=SC1091
source /build.env

: "${GIT_DUMPHFDL:=https://github.com/openwebrx/dumphfdl-debian}"

if [ "${BUILD_DUMPHFDL:-}" == "y" ]; then
	apt install -y \
		libacars-dev libconfig++-dev
	log suc "Building dumphfdl..."
	git clone -b debian/bullseye "$GIT_DUMPHFDL"

	cd dumphfdl-debian/src
	log inf "Applying dumphfdl CMake patch"

	cat <<'EOF' > cmake.patch
--- CMakeLists.txt.orig	2025-11-26 03:45:01.858956332 +0000
+++ CMakeLists.txt	2025-11-26 03:45:17.464192548 +0000
@@ -59,22 +59,8 @@
 set(CMAKE_REQUIRED_INCLUDES ${CMAKE_REQUIRED_INCLUDES} ${LIQUIDDSP_INCLUDE_DIR})
 set(CMAKE_REQUIRED_LIBRARIES_SAVE ${CMAKE_REQUIRED_LIBRARIES})
 set(CMAKE_REQUIRED_LIBRARIES ${CMAKE_REQUIRED_LIBRARIES} ${LIQUIDDSP_LIBRARIES})
-set(LIQUID_VERSION_MIN "1.3.0")
-set(LIQUID_VERSION_NUMBER_MIN 1003000)
-check_c_source_runs("
-#include <stdio.h>
-#include <stdlib.h>
-#include <liquid/liquid.h>
-#if LIQUID_VERSION_NUMBER < ${LIQUID_VERSION_NUMBER_MIN}
-#error LiquidDSP library is too old
-#endif
-int main(void) { LIQUID_VALIDATE_LIBVERSION return 0; }" LIQUIDDSP_VERSION_CHECK)
-if(LIQUIDDSP_VERSION_CHECK)
-	list(APPEND dumphfdl_extra_libs ${LIQUIDDSP_LIBRARIES})
-	list(APPEND dumphfdl_include_dirs ${LIQUIDDSP_INCLUDE_DIR})
-else()
-	message(FATAL_ERROR "LiquidDSP library is too old or missing (min. version required: ${LIQUID_VERSION_MIN})")
-endif()
+list(APPEND dumphfdl_extra_libs ${LIQUIDDSP_LIBRARIES})
+list(APPEND dumphfdl_include_dirs ${LIQUIDDSP_INCLUDE_DIR})
 set(CMAKE_REQUIRED_INCLUDES ${CMAKE_REQUIRED_INCLUDES_SAVE})
 set(CMAKE_REQUIRED_LIBRARIES ${CMAKE_REQUIRED_LIBRARIES_SAVE})
 
EOF

	patch < cmake.patch || log war "dumphfdl patch already applied"
	cd ../..

	tar czf dumphfdl_1.4.1.orig.tar.gz dumphfdl-debian/
	pushd dumphfdl-debian
	dpkg-buildpackage -us -uc
	popd

	# copy debs to the output folder
	cp ./*.deb "${OUTPUT_DIR}/"

	# clean
	rm -rf ./*.deb dumphfdl-debian
fi
