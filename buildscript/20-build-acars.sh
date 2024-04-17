#!/usr/bin/env bash
set -euo pipefail

ARCH=$(uname -m)
OUTPUT_DIR=/usr/src/owrx-output/$ARCH/
mkdir -p $OUTPUT_DIR

apt install libxml2-dev libjansson-dev

mkdir libacars
pushd libacars
wget 'https://raw.githubusercontent.com/openwebrx/package-builder/master/packages/24-libacars/build.sh'
chmod +x build.sh
./build.sh
cp *.deb $OUTPUT_DIR/
dpkg -i *.deb
popd


mkdir acarsdec
pushd acarsdec
wget 'https://raw.githubusercontent.com/openwebrx/package-builder/master/packages/29-acarsdec/build.sh'
chmod +x build.sh
./build.sh
cp *.deb $OUTPUT_DIR/
popd
