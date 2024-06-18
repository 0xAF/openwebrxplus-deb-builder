#!/bin/bash
set -euo pipefail

# read and export dependencies
# shellcheck disable=SC1091
source /build.env

# set default value if not provided
: "${GIT_SOAPYSDRPLAY3:=https://github.com/luarvique/SoapySDRPlay3.git}"

if [ "${BUILD_SOAPYSDRPLAY3:-}" == "y" ]; then
	log suc "Building SoapySDRPlay3..."
	git clone -b master "$GIT_SOAPYSDRPLAY3"
	pushd SoapySDRPlay3
	#case $(uname -m) in
	#	arm*) git checkout 0.8.7 ;;
	#esac
	# SoapySDR v0.7
	HAVE_SOAPY=$(apt-cache search libsoapysdr0.7)
	if [ -n "${HAVE_SOAPY}" ] ; then
		log suc "Building SoapySDRPlay3 v0.7..."
		cp debian/control.debian debian/control
		dpkg-buildpackage -us -uc
	fi
	# SoapySDR v0.8
	HAVE_SOAPY=$(apt-cache search libsoapysdr0.8)
	if [ -n "${HAVE_SOAPY}" ] ; then
		log suc "Building SoapySDRPlay3 v0.8..."
		cp debian/control.ubuntu debian/control
		dpkg-buildpackage -us -uc
	fi
	popd

	# copy debs to the output folder
	cp ./*.deb "${OUTPUT_DIR}/"
	
	# clean
	rm -rf ./*.deb SoapySDRPlay3/
fi

