#!/usr/bin/env bash
set -euo pipefail

# read and export dependencies
# shellcheck disable=SC1091
source /build.env

: "${GIT_DREAM:=https://github.com/wwek/dream}"

if [ "${BUILD_DREAM:-}" == "y" ]; then
	apt remove --autoremove --purge -y libsndfile1-dev libqwt-qt5-dev libasound2-dev libgps-dev libqt5svg5-dev
	log suc "Building dream..."
	git clone -b main "$GIT_DREAM"
	# show cloned commit hash (full + short)
	if git -C dream rev-parse --verify HEAD >/dev/null 2>&1; then
		echo "dream commit: $(git -C dream rev-parse HEAD) ($(git -C dream rev-parse --short HEAD))"
	else
		echo "Unable to determine dream commit hash"
	fi

	pushd dream

	timestamp="$(LC_TIME=C date '+%a, %d %b %Y %T %z')"
	yyyymmdd=$(date +%Y%m%d)
	changelog_message="dream (2.2-$yyyymmdd) unstable; urgency=medium

  * Packaged by LZ2SLL - Stanislav Lechev (0xAF)

 -- Stanislav Lechev <af@0xAF.org>  $timestamp

"
	mkdir -p debian
	tmpfile="$(mktemp /tmp/changelog.XXXXXX)" || tmpfile="/tmp/changelog.$$"
	printf '%s' "$changelog_message" > "$tmpfile"
	if [ -f debian/changelog ]; then
		cat debian/changelog >> "$tmpfile"
	fi
	mv "$tmpfile" debian/changelog

	echo 10 > debian/compat
	# we can skip these overrides below as we are passing -d flag to dpkg-buildpackage
	#sed -i 's/qt5-default, //g' debian/control
	# Disable GPS support in dream.pro by commenting out related lines
	#if [ -f dream.pro ]; then
	#	log inf "Disabling GPS in dream.pro (commenting out HAVE_LIBGPS, -lgps, and gps message)"
	#	# Comment out: DEFINES += HAVE_LIBGPS
	#	sed -i -E '/^[[:space:]]*#/! s/^[[:space:]]*DEFINES[[:space:]]*\+=[[:space:]]*HAVE_LIBGPS/#&/' dream.pro
	#	# Comment out: unix:LIBS += -lgps
	#	sed -i -E '/^[[:space:]]*#/! s/^[[:space:]]*unix:[[:space:]]*LIBS[[:space:]]*\+=[[:space:]]*-lgps/#&/' dream.pro
	#	# Comment out: message("with gps")
	#	sed -i -E '/^[[:space:]]*#/! s/^[[:space:]]*message\("with gps"\)/#&/' dream.pro
	#else
	#	log war "dream.pro not found; skipping GPS disable step"
	#	exit 1
	#fi
	cat >> debian/rules << __EOF__
override_dh_auto_configure:
	dh_auto_configure -- qmake PREFIX=/usr CONFIG+=console CONFIG+=fdk-aac dream.pro || true
__EOF__
	cd ..
	tar czf dream_2.2.orig.tar.gz dream/
	cd -
	dpkg-buildpackage -us -uc -d
	popd

	# copy debs to the output folder
	cp ./*.deb "${OUTPUT_DIR}/"

	# clean
	rm -rf ./*.deb dream
fi
