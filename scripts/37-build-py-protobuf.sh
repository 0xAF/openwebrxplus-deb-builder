#!/bin/bash
set -euo pipefail

# read and export dependencies
# shellcheck disable=SC1091
source /build.env

# python3-protobuf >= 4.21.12 is required by meshtastic.
# bullseye has 3.12.4 (too old); bookworm and newer ship 3.21.12+ds which maps
# to PyPI 4.21.12 and satisfies the requirement.
# protobuf ships compiled C extensions so the wheel is architecture-specific.

if [ "${BUILD_PY_PROTOBUF:-}" == "y" ]; then
	log suc "Building python3-protobuf..."
	export DEBIAN_FRONTEND=noninteractive
	command -v pip3 >/dev/null 2>&1 || apt-get install -y python3-pip

	PKG_VER="4.25.8"
	DEB_NAME="python3-protobuf"
	PY_VER=$(python3 -c 'import sys; print(f"{sys.version_info.major}.{sys.version_info.minor}")')
	ARCH=$(dpkg --print-architecture)

	STAGING=$(mktemp -d)
	mkdir -p "${STAGING}/usr/lib/python3/dist-packages"
	mkdir -p "${STAGING}/DEBIAN"

	pip3 install --no-deps \
		--target "${STAGING}/usr/lib/python3/dist-packages" \
		"protobuf==${PKG_VER}"

	cat > "${STAGING}/DEBIAN/control" <<EOF
Package: ${DEB_NAME}
Version: ${PKG_VER}-1
Architecture: ${ARCH}
Maintainer: OpenWebRX DEB Builder <builder@openwebrx>
Depends: python3 (>= ${PY_VER})
Provides: python3-protobuf
Conflicts: python3-protobuf (<< 4.21.12)
Replaces: python3-protobuf (<< 4.21.12)
Description: Python bindings for protocol buffers (v${PKG_VER})
 Protocol buffers are Google's language-neutral, platform-neutral,
 extensible mechanism for serializing structured data.
 .
 Backport build from PyPI for distributions with python3-protobuf < 4.21.12.
EOF

	dpkg-deb --build "${STAGING}" "${DEB_NAME}_${PKG_VER}-1_${ARCH}.deb"
	apt-get install -y "./${DEB_NAME}_${PKG_VER}-1_${ARCH}.deb"
	cp "${DEB_NAME}_${PKG_VER}-1_${ARCH}.deb" "${OUTPUT_DIR}/"
	rm -rf "${STAGING}" "${DEB_NAME}_${PKG_VER}-1_${ARCH}.deb"
fi
