#!/bin/bash
set -euo pipefail

# read and export dependencies
# shellcheck disable=SC1091
source /build.env

if [ "${BUILD_PY_PACKAGING:-}" == "y" ]; then
	log suc "Building python3-packaging..."
	export DEBIAN_FRONTEND=noninteractive
	command -v pip3 >/dev/null 2>&1 || apt-get install -y python3-pip

	PKG_VER="25.0"
	DEB_NAME="python3-packaging"
	PY_VER=$(python3 -c 'import sys; print(f"{sys.version_info.major}.{sys.version_info.minor}")')

	STAGING=$(mktemp -d)
	mkdir -p "${STAGING}/usr/lib/python3/dist-packages"
	mkdir -p "${STAGING}/DEBIAN"

	pip3 install --no-deps \
		--target "${STAGING}/usr/lib/python3/dist-packages" \
		"packaging==${PKG_VER}"

	cat > "${STAGING}/DEBIAN/control" <<EOF
Package: ${DEB_NAME}
Version: ${PKG_VER}-1
Architecture: all
Maintainer: OpenWebRX DEB Builder <builder@openwebrx>
Depends: python3 (>= ${PY_VER})
Provides: python3-packaging
Conflicts: python3-packaging (<< 24)
Replaces: python3-packaging (<< 24)
Description: core utilities for Python packages (v${PKG_VER})
 This library provides utilities that implement the interoperability
 specifications which have clearly one correct behaviour (PEP 440 versioning,
 PEP 425 platform compatibility tags, etc).
 .
 Backport build from PyPI for distributions without packaging >= 24.
EOF

	dpkg-deb --build "${STAGING}" "${DEB_NAME}_${PKG_VER}-1_all.deb"
	apt-get install -y "./${DEB_NAME}_${PKG_VER}-1_all.deb"
	cp "${DEB_NAME}_${PKG_VER}-1_all.deb" "${OUTPUT_DIR}/"
	rm -rf "${STAGING}" "${DEB_NAME}_${PKG_VER}-1_all.deb"
fi
