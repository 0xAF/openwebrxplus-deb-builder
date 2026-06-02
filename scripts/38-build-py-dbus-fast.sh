#!/bin/bash
set -euo pipefail

# read and export dependencies
# shellcheck disable=SC1091
source /build.env

# python3-dbus-fast is only needed for bullseye (Python 3.9) and jammy (Python 3.10).
# bookworm and noble already have it in apt.
# dbus-fast 2.x requires Python >= 3.11; use last 1.x release for older distros.

if [ "${BUILD_PY_DBUS_FAST:-}" == "y" ]; then
	log suc "Building python3-dbus-fast..."
	export DEBIAN_FRONTEND=noninteractive
	command -v pip3 >/dev/null 2>&1 || apt-get install -y python3-pip

	PY_VER=$(python3 -c 'import sys; print(f"{sys.version_info.major}.{sys.version_info.minor}")')
	if python3 -c 'import sys; exit(0 if sys.version_info >= (3,11) else 1)'; then
		PKG_VER="2.44.1"
		EXTRA_PKGS=""
	else
		PKG_VER="1.93.0"
		# asyncio.timeout was added in Python 3.11; bundle async-timeout for older distros
		EXTRA_PKGS="async-timeout"
	fi
	DEB_NAME="python3-dbus-fast"

	log inf "Python ${PY_VER} detected, building dbus-fast ${PKG_VER}..."

	STAGING=$(mktemp -d)
	mkdir -p "${STAGING}/usr/lib/python3/dist-packages"
	mkdir -p "${STAGING}/DEBIAN"

	# shellcheck disable=SC2086
	pip3 install --no-deps \
		--target "${STAGING}/usr/lib/python3/dist-packages" \
		"dbus-fast==${PKG_VER}" ${EXTRA_PKGS}

	cat > "${STAGING}/DEBIAN/control" <<EOF
Package: ${DEB_NAME}
Version: ${PKG_VER}-1
Architecture: all
Maintainer: OpenWebRX DEB Builder <builder@openwebrx>
Depends: python3 (>= ${PY_VER})
Description: faster version of dbus-next (Python 3)
 dbus-fast is a pure Python implementation of the D-Bus protocol.
 It is intended as a faster alternative to dbus-python and dbus-next,
 used by bluetooth libraries such as bleak for BLE communication.
 .
 Backport build from PyPI for distributions without this package.
EOF

	dpkg-deb --build "${STAGING}" "${DEB_NAME}_${PKG_VER}-1_all.deb"
	apt-get install -y "./${DEB_NAME}_${PKG_VER}-1_all.deb"
	cp "${DEB_NAME}_${PKG_VER}-1_all.deb" "${OUTPUT_DIR}/"
	rm -rf "${STAGING}" "${DEB_NAME}_${PKG_VER}-1_all.deb"
fi
