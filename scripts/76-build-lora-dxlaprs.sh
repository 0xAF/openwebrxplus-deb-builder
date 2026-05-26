#!/usr/bin/env bash
set -euo pipefail

# read and export dependencies
# shellcheck disable=SC1091
source /build.env

SRC_URL="http://oe5dxl.hamspirit.at:8025/aprs/c/"
PKG_NAME="dxlaprs-lora"

if [ "${BUILD_LORA_DXLAPRS:-}" == "y" ]; then
	log suc "Building dxlAPRS LoRa tools (lorarx, loratx)..."
	export DEBIAN_FRONTEND=noninteractive
	# We have these packages already in the base image, so we can skip installing them here:
	#apt-get install -y --no-install-recommends \
	#	build-essential \
	#	debhelper \
	#	dpkg-dev \
	#	fakeroot \
	#	wget

	rm -rf lora-dxlaprs
	mkdir lora-dxlaprs
	pushd lora-dxlaprs

	# Download all C sources, headers, and Makefiles from the dxlAPRS toolchain server
	log inf "Downloading sources from ${SRC_URL}..."
	wget -nv --no-proxy -r -np -nd -l1 -A "*.c,*.h,Makefile*" "${SRC_URL}" || {
		log err "Failed to download sources from ${SRC_URL}"
		exit 1
	}

	# Fix osic.c: add explicit casts to silence -Werror=implicit on newer GCC
	sed -i 's/return ctime(time0);/return (int32_t)ctime((time_t*)time0);/' osic.c

	make lorarx
	make loratx

	pkg_version="1.0.$(date +%Y%m%d)"
	debian_dir="debian"
	rm -rf "${debian_dir}"
	mkdir -p "${debian_dir}/source"
	changelog_date=$(LC_ALL=C date -Ru)

	cat > "${debian_dir}/changelog" <<EOF
${PKG_NAME} (${pkg_version}) unstable; urgency=medium

  * Automated build from ${SRC_URL}

 -- OpenWebRX DEB Builder <builder@openwebrx>  ${changelog_date}
EOF

	cat > "${debian_dir}/control" <<EOF
Source: ${PKG_NAME}
Section: hamradio
Priority: optional
Maintainer: OpenWebRX DEB Builder <builder@openwebrx>
Build-Depends: debhelper (>= 13)
Standards-Version: 4.6.2
Homepage: http://oe5dxl.hamspirit.at:8025/aprs/c/
Rules-Requires-Root: no

Package: ${PKG_NAME}
Architecture: any
Depends: \${shlibs:Depends}, \${misc:Depends}
Description: LoRa tools from the dxlAPRS Toolchain by Christian Rabler (OE5DXL)
 This package provides lorarx and loratx, part of the dxlAPRS toolchain
 created by Christian Rabler (OE5DXL).
 .
 lorarx is a LoRa IQ demodulator with AXUDP interface supporting APRS and
 LoRaWAN packet decoding from SDR IQ input.
 .
 loratx encodes beacon/packet text to LoRa IQ files for RF transmission
 or demodulator testing.
 .
 Project homepage: http://oe5dxl.hamspirit.at:8025/aprs/c/
EOF

	cat > "${debian_dir}/compat" <<'EOF'
13
EOF

	cat > "${debian_dir}/source/format" <<'EOF'
3.0 (native)
EOF

	cat > "${debian_dir}/rules" <<'EOF'
#!/usr/bin/make -f
export DH_VERBOSE := 1

%:
	dh $@

override_dh_auto_clean:
	@true

override_dh_auto_configure:
	@true

override_dh_auto_build:
	@true

override_dh_auto_install:
	dh_install
EOF
	chmod +x "${debian_dir}/rules"

	cat > "${debian_dir}/${PKG_NAME}.install" <<'EOF'
lorarx usr/bin/
loratx usr/bin/
EOF

	dpkg-buildpackage -b -us -uc -j"$(nproc --ignore=4)"
	popd

	mkdir -p "${OUTPUT_DIR}"
	shopt -s nullglob
	debs=(${PKG_NAME}_*.deb)
	shopt -u nullglob
	if [ ${#debs[@]} -eq 0 ]; then
		log err "dxlaprs-lora deb package missing"
		exit 1
	fi
	for deb in "${debs[@]}"; do
		cp "$deb" "${OUTPUT_DIR}/"
	done

	rm -f ${PKG_NAME}_*
	rm -rf lora-dxlaprs
fi
