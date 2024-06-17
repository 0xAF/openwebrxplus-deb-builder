#!/usr/bin/env bash
set -euo pipefail

ARCH=$(uname -m)
OUTPUT_DIR=/usr/src/owrx-output/$ARCH/
mkdir -p $OUTPUT_DIR

if [ "${BUILD_ACARSDEC:-}" == "y" ]; then
  apt install -y libxml2-dev libjansson-dev

  if [ "${COMPILE_LIBACARS_FROM_JAKOB:-}" == "y" ]; then
    # use Jakob's version of libacars
    mkdir libacars
    pushd libacars
      wget 'https://raw.githubusercontent.com/openwebrx/package-builder/master/packages/24-libacars/build.sh'
      chmod +x build.sh
      ./build.sh
      cp *.deb $OUTPUT_DIR/
      dpkg -i *.deb
    popd
  else
    # or use our version in the ppa repo
    wget -O - https://luarvique.github.io/ppa/openwebrx-plus.gpg | gpg --dearmor -o /etc/apt/trusted.gpg.d/openwebrx-plus.gpg
    echo "deb [signed-by=/etc/apt/trusted.gpg.d/openwebrx-plus.gpg] https://luarvique.github.io/ppa/bookworm ./" > /etc/apt/sources.list.d/openwebrx-plus.list
    apt update
    apt install -y libacars-dev
  fi

  # now build acarsdec
  mkdir acarsdec
  pushd acarsdec
  wget 'https://raw.githubusercontent.com/openwebrx/package-builder/master/packages/29-acarsdec/build.sh'
  chmod +x build.sh
  ./build.sh
  cp *.deb $OUTPUT_DIR/
  popd

fi
