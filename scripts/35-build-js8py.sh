#!/bin/bash
set -euo pipefail

# read and export dependencies
# shellcheck disable=SC1091
source /build.env

# set default value if not provided
: "${GIT_JS8PY:=https://github.com/jketterl/js8py.git}"

if [ "${BUILD_JS8PY:-}" == "y" ]; then
	log suc "Building JS8Py..."
	git clone -b master "$GIT_JS8PY"
	pushd js8py
	dpkg-buildpackage -us -uc
	popd
	# Not installing JS8Py here since there are no further
	# build steps depending on it
	#sudo dpkg -i *js8py*.deb

	# copy debs to the output folder
	cp ./*.deb "${OUTPUT_DIR}/"
	
	# clean
	rm -rf ./*.deb js8py/
fi

