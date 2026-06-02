#!/bin/bash
set -euo pipefail

# This script should check what software we want to build
# and should include the correct dependencies to be built before that.

if [ "${BUILD_OWRX:-}" == "y" ]; then
  export BUILD_PYCSDR=y
  export BUILD_OWRXCONNECTOR=y
fi
if [ "${BUILD_PYCSDR_ETI:-}" == "y" ]; then
  export BUILD_CSDR_ETI=y
fi
if [ "${BUILD_PYDIGIHAM:-}" == "y" ]; then
  export BUILD_DIGIHAM=y
fi
if [ "${BUILD_DIGIHAM:-}" == "y" ]; then
  export BUILD_CODECSERVER=y
fi
if [ "${BUILD_PYCSDR:-}" == "y" ] || [ "${BUILD_OWRXCONNECTOR:-}" == "y" ] || [ "${BUILD_CSDR_ETI:-}" == "y" ] || [ "${BUILD_SKIMMER:-}" == "y" ]; then
  export BUILD_CSDR=y
fi
if [ "${BUILD_ACARSDEC:-}" == 'y' ] || [ "${BUILD_DUMPHFDL:-}" == "y" ] || [ "${BUILD_DUMPVDL2:-}" == "y" ]; then
  export BUILD_LIBACARS=y
fi
# Check if apt has a package at (optionally) a minimum version.
# Uses the candidate version from apt-cache policy so it works before installation.
# Usage: apt_has_version PKG [MIN_VERSION]
apt_has_version() {
  local pkg="$1"
  local min_ver="${2:-}"
  local candidate
  candidate=$(apt-cache policy "$pkg" 2>/dev/null | awk '/Candidate:/ {print $2}')
  if [ -z "$candidate" ] || [ "$candidate" = "(none)" ]; then
    return 1
  fi
  if [ -n "$min_ver" ]; then
    dpkg --compare-versions "$candidate" ge "$min_ver"
  fi
}

if [ "${BUILD_MESHTASTIC:-}" == "y" ]; then
  apt_has_version python3-packaging 24.0   || export BUILD_PY_PACKAGING=y
  apt_has_version python3-dbus-fast        || export BUILD_PY_DBUS_FAST=y
  apt_has_version python3-dotmap           || export BUILD_PY_DOTMAP=y
  apt_has_version python3-bleak 0.22.3     || export BUILD_PY_BLEAK=y
  apt_has_version python3-protobuf 4.21.12 || export BUILD_PY_PROTOBUF=y
fi

colorify() {
  [[ $2 ]] && {
    local yn=${1:-n}
    shift
  }
  local name=${1:-}

  case $yn in
	y*) log inf "${name}: [2[${yn}]]" ;;
	*) log inf "${name}: [3[${yn}]]" ;;
  esac
}

log log "Building:"
colorify "${BUILD_OWRX:-n}" OpenWebRx
colorify "${BUILD_CSDR:-n}" csdr
colorify "${BUILD_APRS_SYMBOLS:-n}" aprs-symbols
colorify "${BUILD_PYCSDR:-n}" pycsdr
colorify "${BUILD_OWRXCONNECTOR:-n}" OWRX-Connector
colorify "${BUILD_CODECSERVER:-n}" Codec-Server
colorify "${BUILD_DIGIHAM:-n}" digiham
colorify "${BUILD_PYDIGIHAM:-n}" pydigiham
colorify "${BUILD_CSDR_ETI:-n}" csdr-eti
colorify "${BUILD_PYCSDR_ETI:-n}" pycsdr-eti
colorify "${BUILD_JS8PY:-n}" js8py
colorify "${BUILD_PY_PACKAGING:-n}" python3-packaging
colorify "${BUILD_PY_PROTOBUF:-n}" python3-protobuf
colorify "${BUILD_PY_DBUS_FAST:-n}" python3-dbus-fast
colorify "${BUILD_PY_DOTMAP:-n}" python3-dotmap
colorify "${BUILD_PY_BLEAK:-n}" python3-bleak
colorify "${BUILD_MESHTASTIC:-n}" meshtastic
colorify "${BUILD_REDSEA:-n}" redsea
colorify "${BUILD_SOAPYSDRPLAY3:-n}" SoapySDRPlay3
colorify "${BUILD_LIBACARS:-n}" LibAcars
colorify "${BUILD_ACARSDEC:-n}" AcarsDec
colorify "${BUILD_NRSC5:-n}" nrsc5
colorify "${BUILD_SKIMMER:-n}" skimmer
colorify "${BUILD_DUMP978:-n}" dump978
colorify "${BUILD_DUMP1090:-n}" dump1090
colorify "${BUILD_DUMPHFDL:-n}" dumphfdl
colorify "${BUILD_DUMPVDL2:-n}" dumpvdl2
colorify "${BUILD_HPSDR:-n}" hpsdr
colorify "${BUILD_DREAM:-n}" dream
colorify "${BUILD_SONDE:-n}" sonde
colorify "${BUILD_RTL433:-n}" rtl433
colorify "${BUILD_RADAE:-n}" radae
colorify "${BUILD_MULTIMON_NG:-n}" multimon-ng
colorify "${BUILD_LORA_DXLAPRS:-n}" dxlaprs-lora

sleep 3

echo "set -a" > /build.env
printenv | grep -E ^BUILD_ >> /build.env
echo "set +a" >> build.env
echo "cd /" >> build.env

