#!/usr/bin/env bash

set -eu

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
    mkdir -p cpts/archives prjs/archives areas/archives rsrs/archives .chnots
}

bs_archive() {
    local _d="$(realpath -s "$1")"
    local _t="${1##*/}"
    local archive_dir="${_d%/*}/archives"
    if [ -d "$archive_dir" ]; then
        mv -T "$_d" "$archive_dir/$_t"
    fi
}

bs_help() {
    echo 'Personal Knowledge Management

  init -- create basic dirs in the current dir.
  spec -- show file structure intructions.
  arch -- archive
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
    arch)
	shift
        bs_archive "$1"
        exit
        ;;
    help)
        bs_help
        exit
        ;;
esac

bs_help
