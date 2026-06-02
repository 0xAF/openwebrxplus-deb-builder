#!/bin/bash
set -euo pipefail

# read and export dependencies
# shellcheck disable=SC1091
source /build.env

if [ "${BUILD_PY_DOTMAP:-}" == "y" ]; then
	log suc "Building python3-dotmap..."
	export DEBIAN_FRONTEND=noninteractive
	command -v pip3 >/dev/null 2>&1 || apt-get install -y python3-pip

	PKG_VER="1.3.30"
	DEB_NAME="python3-dotmap"
	PY_VER=$(python3 -c 'import sys; print(f"{sys.version_info.major}.{sys.version_info.minor}")')

	STAGING=$(mktemp -d)
	mkdir -p "${STAGING}/usr/lib/python3/dist-packages"
	mkdir -p "${STAGING}/DEBIAN"

	pip3 install --no-deps \
		--target "${STAGING}/usr/lib/python3/dist-packages" \
		"dotmap==${PKG_VER}"

	cat > "${STAGING}/DEBIAN/control" <<EOF
Package: ${DEB_NAME}
Version: ${PKG_VER}-1
Architecture: all
Maintainer: OpenWebRX DEB Builder <builder@openwebrx>
Depends: python3 (>= ${PY_VER})
Description: ordered, dynamically-expandable dot-access dictionary
 DotMap is a dot-access dictionary subclass that has dynamic child
 dot-access map creation, can be initialized with existing dictionaries,
 can be pickled, has equal operator testing, and can be converted back
 to a dictionary.
 .
 Backport build from PyPI for distributions without this package.
EOF

	dpkg-deb --build "${STAGING}" "${DEB_NAME}_${PKG_VER}-1_all.deb"
	apt-get install -y "./${DEB_NAME}_${PKG_VER}-1_all.deb"
	cp "${DEB_NAME}_${PKG_VER}-1_all.deb" "${OUTPUT_DIR}/"
	rm -rf "${STAGING}" "${DEB_NAME}_${PKG_VER}-1_all.deb"
fi
