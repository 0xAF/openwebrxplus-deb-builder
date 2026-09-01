#!/bin/bash
set -euo pipefail

# read and export dependencies
# shellcheck disable=SC1091
source /build.env

# set default value if not provided
#: "${GIT_REDSEA:=https://github.com/luarvique/redsea.git}"
: "${GIT_REDSEA:=https://github.com/windytan/redsea.git}"

if [ "${BUILD_REDSEA:-}" == "y" ]; then
	apt install -y nlohmann-json3-dev meson || true
	log suc "Building Redsea..."
	git clone -b master "$GIT_REDSEA"
	pushd redsea
	dpkg-buildpackage -b -us -uc -j"$(nproc --ignore=4)"
	popd

	redsea_debs=(./redsea_*.deb)
	if [ ! -e "${redsea_debs[0]}" ]; then
		log err "Redsea package was not produced"
		exit 1
	fi
	for deb in "${redsea_debs[@]}"; do
		package_contents="$(LC_ALL=C dpkg-deb --contents "$deb")"
		if ! grep -qE ' \./usr/bin/redsea$' <<< "$package_contents"; then
			log err "$deb does not install /usr/bin/redsea"
			exit 1
		fi
		if grep -qE ' \./usb/' <<< "$package_contents"; then
			log err "$deb contains the invalid /usb path"
			exit 1
		fi
	done

	# Not installing Redsea here since there are no further
	# build steps depending on it
	#dpkg -i *redsea*.deb

	# copy debs to the output folder
	cp ./*.deb "${OUTPUT_DIR}/"

	# clean
	rm -rf ./*.deb redsea/
fi
