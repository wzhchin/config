#!/usr/bin/env bash

set -eu

SCRIPT_DIR="$(dirname "$(realpath "$0")")"
cd "$SCRIPT_DIR"

P_PKG=true
PKGS=(openssh vim zsh git gdu uv fzf git-lfs wget ripgrep)

P_PKG=true
PIP_TOOLSS=(yt-dlp)

P_IMMICH=false
IMMICH_GO_URL="https://github.com/simulot/immich-go/releases/download/v0.31.0/immich-go_Linux_arm64.tar.gz"

BIN_DIR="$HOME/.local/bin"
mkdir -p "$BIN_DIR"




init_immich() {
	local tdir=$(mktemp -d)
	echo "tmpdir $tdir"
	cd "$tdir"
	wget "$IMMICH_GO_URL" -O "immich-go.tar.gz" > download.log
	tar -xvf immich-go.tar.gz 
	mv immich-go "$BIN_DIR"
}

init_pkg() {
	pkg update -y && pkg upgrade -y

	pkg install "${PKGS[@]}" -y
}

init_pip() {
	for p in "${PIP_TOOLS[@]}"; do
		uv tool install "$p"
	done
}
init_immich() {
	install_immich
}

init_git() {
	git config --global user.name 'termux'
	git config --global user.email 'termux@chin.internal'
}

while [ $# -gt 0 ]; do
	case "$1" in
		--immich) P_IMMICH=true ;;
	esac
done

init_pkg
init_git
init_pip
if $P_IMMICH; then
	init_immich
fi
