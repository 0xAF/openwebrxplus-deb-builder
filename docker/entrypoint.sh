#!/bin/sh

fail() {
  printf "FAIL: %s\n" "$1"
  if [ -t 1 ]; then
    echo;echo;echo "Dropping into a shell... (you probably want to: cd /usr/src/)"
    exec /bin/bash
  else
    exit 1
  fi
}

"${@}" || fail "build error"
