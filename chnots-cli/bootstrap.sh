#!/usr/bin/env bash

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

source "$SCRIPT_DIR/spec.sh"

bs_init() {
    if ! [ -f AGENTS.md ]; then
	cat <<EOF > AGENTS.md
This dir is a chnot knowledge dir.

Based on PARA and Code.

Try to use \`chnots-cli spec\` or \`chnots-cli help\`.
EOF
	fi
    mkdir -p cpts prjs areas rsrs archives .chnots
}

bs_help() {
  echo 'Personal Knowledge Management

  init -- create basic dirs in the current dir.
  spec -- show file structure intructions.
  '
}

case "$1" in 
  init)
    bs_init
    exit
    ;;
  spec)
    spec_print
    exit
    ;;
  help)
    bs_help
    exit
    ;;
esac

bs_help
