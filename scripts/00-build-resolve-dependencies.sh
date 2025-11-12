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
if [ "${BUILD_ACARSDEC:-}" == 'y' ]; then
  export BUILD_LIBACARS=y
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
colorify "${BUILD_PYCSDR:-n}" pycsdr
colorify "${BUILD_OWRXCONNECTOR:-n}" OWRX-Connector
colorify "${BUILD_CODECSERVER:-n}" Codec-Server
colorify "${BUILD_DIGIHAM:-n}" digiham
colorify "${BUILD_PYDIGIHAM:-n}" pydigiham
colorify "${BUILD_CSDR_ETI:-n}" csdr-eti
colorify "${BUILD_PYCSDR_ETI:-n}" pycsdr-eti
colorify "${BUILD_JS8PY:-n}" js8py
colorify "${BUILD_REDSEA:-n}" redsea
colorify "${BUILD_SOAPYSDRPLAY3:-n}" SoapySDRPlay3
colorify "${BUILD_ACARSDEC:-n}" AcarsDec
colorify "${BUILD_LIBACARS:-n}" LibAcars
colorify "${BUILD_NRSC5:-n}" nrsc5
colorify "${BUILD_SKIMMER:-n}" skimmer
colorify "${BUILD_DUMP978:-n}" dump978
colorify "${BUILD_DREAM:-n}" dream

sleep 3

echo "set -a" > /build.env
printenv | grep -E ^BUILD_ >> /build.env
echo "set +a" >> build.env
echo "cd /" >> build.env

