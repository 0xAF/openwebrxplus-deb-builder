#!/bin/bash
# shellcheck disable=SC1091
source /log.sh
export -f log # make log function availabe to the build scripts

die() {
  if [[ $(type -t log) == function ]]; then
    echo;echo;echo;log err "$*"
  else
    echo;echo;echo;echo "$*"
  fi
  exit 1
}

if [ -n "$APT_PROXY" ]; then
  log inf "Setting APT-PROXY: [3[${APT_PROXY}]]"
  export http_proxy=${APT_PROXY}
  echo "Acquire::http { Proxy \"${APT_PROXY}\"; };" > /etc/apt/apt.conf.d/51cache
else
  rm -f /etc/apt/apt.conf.d/51cache
fi

# Do some checks
[ -d /output ] || die "ERROR: /output is not mounted"
[ -f /settings.env ] || die "ERROR: /settings.env is missing"
[ -d /scripts ] || die "ERROR: /scripts is not mounted"
[ -z "${OUTPUT_DIR}" ] && die "ERROR: OUTPUT_DIR is not set"

cd / || die "cannot change dir to /"

set -a # export defined variables automatically
source /settings.env
set +a

log inf "APT update/upgrade"
apt update
apt upgrade -y

log suc "Clean the output folder ${OUTPUT_DIR}"
rm -rf "${OUTPUT_DIR:-}"/*

log suc "Running build scripts..."
# shellcheck disable=SC2045
for s in $(ls -v /scripts/*-build-*.sh); do
  if [ -x "${s}" ]; then 
    echo;echo
    log inf "Running build script [4[${s}]]"
    echo;echo
    "${s}" || exit 1
    echo;echo
    log inf "Done with build script [4[${s}]]"
  else
    log war "Skipping build script [4[${s}]]. It is not executable."
  fi
done

# Correct ownership of the artifacts.
# Without this, the artifacts directory and it's contents end up owned
# by root instead of the local user on Linux boxes
chown -R --reference="${OUTPUT_DIR}" "${OUTPUT_DIR}"/* || true
