#!/usr/bin/env bash
set -euo pipefail

# read and export dependencies
# shellcheck disable=SC1091
source /build.env

: "${GIT_DREAM:=https://github.com/wwek/dream}"

if [ "${BUILD_DREAM:-}" == "y" ]; then
	log suc "Building dream..."
	git clone -b main "$GIT_DREAM"
	pushd dream
	echo 10 > debian/compat
	sed -i 's/qt5-default, //g' debian/control
	# Disable GPS support in dream.pro by commenting out related lines
	if [ -f dream.pro ]; then
		log inf "Disabling GPS in dream.pro (commenting out HAVE_LIBGPS, -lgps, and gps message)"
		# Comment out: DEFINES += HAVE_LIBGPS
		sed -i -E '/^[[:space:]]*#/! s/^[[:space:]]*DEFINES[[:space:]]*\+=[[:space:]]*HAVE_LIBGPS/#&/' dream.pro
		# Comment out: unix:LIBS += -lgps
		sed -i -E '/^[[:space:]]*#/! s/^[[:space:]]*unix:[[:space:]]*LIBS[[:space:]]*\+=[[:space:]]*-lgps/#&/' dream.pro
		# Comment out: message("with gps")
		sed -i -E '/^[[:space:]]*#/! s/^[[:space:]]*message\("with gps"\)/#&/' dream.pro
	else
		log war "dream.pro not found; skipping GPS disable step"
		exit 1
	fi
	cat >> debian/rules << __EOF__
override_dh_auto_configure:
	dh_auto_configure -- qmake PREFIX=/usr CONFIG+=console CONFIG+=fdk-aac dream.pro || true
__EOF__
	cd ..
	tar czf dream_2.2.orig.tar.gz dream/
	cd -
	dpkg-buildpackage -us -uc
	popd

	# copy debs to the output folder
	cp ./*.deb "${OUTPUT_DIR}/"

	# clean
	rm -rf ./*.deb dream
fi
