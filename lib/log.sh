#!/usr/bin/env bash
# https://github.com/vtmx/logsh/blob/main/log

function log() {
  # Get status if exist
  [[ $2 ]] && {
    local status=$1
    shift
  }

  # Get message
  local msg="${1:-}"

  # Add style in msg
  case $status in
  err*)
    status=ERR
    msgo="\e[37;1m::: \e[31;1m[${status}] \e[37;1m->\e[0m $msg"
    ;;
  suc*)
    status=SUC
    msgo="\e[37;1m::: \e[32;1m[${status}] \e[37;1m->\e[0m $msg"
    ;;
  war*)
    status=WAR
    msgo="\e[37;1m::: \e[33;1m[${status}] \e[37;1m->\e[0m $msg"
    ;;
  inf*)
    status=INF
    msgo="\e[37;1m::: \e[34;1m[${status}] \e[37;1m->\e[0m $msg"
    ;;
  *)
    status=LOG
    msgo="\e[37;1m::: \e[30;1m[$status] \e[37;1m->\e[0m $msg"
    ;;
  esac

  # Show message in screen hightlight 'words'
  echo -e "$(
    sed -E \
    -e "s/'(.[^']*)'/\\\e[36;1m'\\\e[32;1m\1\\\e[36;1m'\\\e[0m/g" \
    -e "s/\[1\[(.[^]]*)\]\]/\\\e[31m\1\\\e[0m/g" \
    -e "s/\[2\[(.[^]]*)\]\]/\\\e[32m\1\\\e[0m/g" \
    -e "s/\[3\[(.[^]]*)\]\]/\\\e[33m\1\\\e[0m/g" \
    -e "s/\[4\[(.[^]]*)\]\]/\\\e[34m\1\\\e[0m/g" \
    -e "s/\[5\[(.[^]]*)\]\]/\\\e[35m\1\\\e[0m/g" \
    -e "s/\[6\[(.[^]]*)\]\]/\\\e[36m\1\\\e[0m/g" \
    -e "s/\[7\[(.[^]]*)\]\]/\\\e[37m\1\\\e[0m/g" \
    <<<"$msgo"
  )"
}
