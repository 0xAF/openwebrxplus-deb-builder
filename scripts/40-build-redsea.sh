#!/bin/bash
set -euo pipefail

# read and export dependencies
# shellcheck disable=SC1091
source /build.env

# set default value if not provided
: "${GIT_REDSEA:=https://github.com/luarvique/redsea.git}"

if [ "${BUILD_REDSEA:-}" == "y" ]; then
	log suc "Building Redsea..."
	git clone -b master "$GIT_REDSEA"
	pushd redsea
	. /etc/os-release
	if [[ "$UBUNTU_CODENAME" == "jammy" || "$UBUNTU_CODENAME" == "noble" ]]; then
		# this is for ubuntu 22.04/24.04
		echo '---------- oooohh, it is an ubuntu....'
		apt install -y nlohmann-json3-dev meson || true
		echo "debian/redsea/usr/bin/redsea /usb/bin" > debian/install
	fi
	dpkg-buildpackage -us -uc
	popd
	# Not installing Redsea here since there are no further
	# build steps depending on it
	#dpkg -i *redsea*.deb

	# copy debs to the output folder
	cp ./*.deb "${OUTPUT_DIR}/"
	
	# clean
	rm -rf ./*.deb redsea/
fi

