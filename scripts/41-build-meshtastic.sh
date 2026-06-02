#!/bin/bash
set -euo pipefail

# read and export dependencies
# shellcheck disable=SC1091
source /build.env

if [ "${BUILD_MESHTASTIC:-}" == "y" ]; then
	log suc "Building python3-meshtastic..."
	export DEBIAN_FRONTEND=noninteractive
	command -v pip3 >/dev/null 2>&1 || apt-get install -y python3-pip

	MESH_VER="2.7.7"
	DEB_NAME="python3-meshtastic"
	PY_VER=$(python3 -c 'import sys; print(f"{sys.version_info.major}.{sys.version_info.minor}")')

	STAGING=$(mktemp -d)
	mkdir -p "${STAGING}/usr/lib/python3/dist-packages"
	mkdir -p "${STAGING}/DEBIAN"

	# meshtastic and PyPubSub (pypubsub is not packaged in Debian/Ubuntu main)
	pip3 install --no-deps \
		--target "${STAGING}/usr/lib/python3/dist-packages" \
		"meshtastic==${MESH_VER}" PyPubSub

	cat > "${STAGING}/DEBIAN/control" <<EOF
Package: ${DEB_NAME}
Version: ${MESH_VER}-1
Architecture: all
Maintainer: OpenWebRX DEB Builder <builder@openwebrx>
Depends: python3 (>= ${PY_VER}), python3-serial, python3-protobuf, python3-tabulate, python3-requests, python3-yaml, python3-bleak, python3-packaging, python3-dotmap
Description: Python API for Meshtastic LoRa radio devices (v${MESH_VER})
 Python API and command-line tool for interacting with Meshtastic LoRa
 radio mesh networking devices. Supports BLE, serial and network connections.
 .
 Build from PyPI for OpenWebRX+ integration.
EOF

	dpkg-deb --build "${STAGING}" "${DEB_NAME}_${MESH_VER}-1_all.deb"
	apt-get install -y "./${DEB_NAME}_${MESH_VER}-1_all.deb"
	cp "${DEB_NAME}_${MESH_VER}-1_all.deb" "${OUTPUT_DIR}/"
	rm -rf "${STAGING}" "${DEB_NAME}_${MESH_VER}-1_all.deb"
fi
