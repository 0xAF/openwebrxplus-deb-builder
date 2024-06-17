#!/bin/sh

fail() {
  printf "\n\n\nFAIL: %s\n" "$1"
  if [ -t 1 ]; then
    echo;echo;echo "Dropping into a shell..."
    cd /
    exec /bin/bash
  else
    exit 1
  fi
}

"${@}" || fail "build error"
