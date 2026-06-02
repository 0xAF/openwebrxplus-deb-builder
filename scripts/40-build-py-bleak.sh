#!/bin/bash
set -euo pipefail

# read and export dependencies
# shellcheck disable=SC1091
source /build.env

# python3-bleak >= 0.22.3 is required by meshtastic.
# trixie already has 0.22.3 in apt; all other distros need this build.

if [ "${BUILD_PY_BLEAK:-}" == "y" ]; then
	log suc "Building python3-bleak..."
	export DEBIAN_FRONTEND=noninteractive
	command -v pip3 >/dev/null 2>&1 || apt-get install -y python3-pip

	PKG_VER="0.22.3"
	DEB_NAME="python3-bleak"
	PY_VER=$(python3 -c 'import sys; print(f"{sys.version_info.major}.{sys.version_info.minor}")')

	STAGING=$(mktemp -d)
	mkdir -p "${STAGING}/usr/lib/python3/dist-packages"
	mkdir -p "${STAGING}/DEBIAN"

	pip3 install --no-deps \
		--target "${STAGING}/usr/lib/python3/dist-packages" \
		"bleak==${PKG_VER}"

	cat > "${STAGING}/DEBIAN/control" <<EOF
Package: ${DEB_NAME}
Version: ${PKG_VER}-1
Architecture: all
Maintainer: OpenWebRX DEB Builder <builder@openwebrx>
Depends: python3 (>= ${PY_VER}), python3-dbus-fast
Provides: python3-bleak
Conflicts: python3-bleak (<< 0.22.3)
Replaces: python3-bleak (<< 0.22.3)
Description: Bluetooth Low Energy platform agnostic client (Python 3)
 An OS independent Bluetooth Low Energy (BLE) client for Python using
 asyncio. Communicates with BLE devices via the OS Bluetooth stack.
 On Linux, it uses D-Bus via dbus-fast.
 .
 Backport build from PyPI for distributions with older or missing bleak.
EOF

	dpkg-deb --build "${STAGING}" "${DEB_NAME}_${PKG_VER}-1_all.deb"
	apt-get install -y "./${DEB_NAME}_${PKG_VER}-1_all.deb"
	cp "${DEB_NAME}_${PKG_VER}-1_all.deb" "${OUTPUT_DIR}/"
	rm -rf "${STAGING}" "${DEB_NAME}_${PKG_VER}-1_all.deb"
fi
