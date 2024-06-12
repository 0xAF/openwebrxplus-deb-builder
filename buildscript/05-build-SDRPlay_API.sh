#!/usr/bin/env bash
set -euo pipefail


ARCH=$(uname -m)
cd /usr/src

echo "+++++ Installing SDRPlay API"
case $ARCH in
  arm*) SDRPLAY_BINARY=SDRplay_RSP_API-Linux-3.15.2.run ;;
  aarch64*) SDRPLAY_BINARY=SDRplay_RSP_API-Linux-3.15.2.run ;;
  x86_64*) SDRPLAY_BINARY=SDRplay_RSP_API-Linux-3.15.2.run ;;
esac
wget --no-http-keep-alive https://www.sdrplay.com/software/$SDRPLAY_BINARY
sh $SDRPLAY_BINARY --noexec --target sdrplay
patch --verbose -Np0 < ./buildscript/patches/$SDRPLAY_BINARY.patch
pushd sdrplay
mkdir -p /etc/udev/rules.d
./install_lib.sh
popd
rm -rf sdrplay $SDRPLAY_BINARY

