#!/usr/bin/env bash

set -e

PKGS=(openssh vim zsh git gdu uv)
PIP_TOOLSS=(yt-dlp)
IMMICH_GO_URL="https://github.com/simulot/immich-go/releases/download/v0.31.0/immich-go_Linux_arm64.tar.gz"

BIN_DIR="$HOME/.local/bin"

install_immich() {
  local tdir=$(mktemp -d)
  echo "tmpdir $tdir"
  cd "$tdir"
  wget "$IMMICH_GO_URL" -O "immich-go.tar.gz" > download.log
  tar -xvf immich-go.tar.gz 
  mv immich-go "$BIN_DIR"
}

pkg install "${PKGS[@]}"

for p in "${PIP_TOOLS[@]}"; do
  uv tool install "$p"
done

mkdir -p "$BIN_DIR"
install_immich
