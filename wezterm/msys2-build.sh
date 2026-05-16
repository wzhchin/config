#!/usr/bin/env bash

MINGW_PACKAGE_PREFIX=mingw-w64-ucrt-x86_64

PACKAGES=("${MINGW_PACKAGE_PREFIX}-openssl"
	"${MINGW_PACKAGE_PREFIX}-libgit2"
	"${MINGW_PACKAGE_PREFIX}-libssh2"
#	"${MINGW_PACKAGE_PREFIX}-rust"
	"${MINGW_PACKAGE_PREFIX}-pkgconf"
	"${MINGW_PACKAGE_PREFIX}-zstd"
	"${MINGW_PACKAGE_PREFIX}-openssl"
	'git')

pacman -S --needed "${PACKAGES[@]}"

export LIBGIT2_NO_VENDOR=1
export OPENSSL_NO_VENDOR=1
export ZSTD_SYS_USE_PKG_CONFIG=1
export LIBSSH2_SYS_USE_PKG_CONFIG=1
#   = note: D:/msys64/ucrt64/bin/../lib/gcc/x86_64-w64-mingw32/15.2.0/../../../../x86_64-w64-mingw32/bin/ld.exe: cannot find -lwinapi_ntdll: No such file or directory␍
#        collect2.exe: error: ld returned 1 exit status
# export WINAPI_NO_BUNDLED_LIBRARIES=1

cargo build --release --frozen --features distro-defaults -p wezterm-gui
