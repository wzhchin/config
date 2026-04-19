#!/usr/bin/env bash

set -eu

UPLOAD_DIRS=(
  /sdcard/DCIM 
  /sdcard/Pictures/QQ 
  /sdcard/Pictures/WeiXin 
  /sdcard/Pictures/Screenshots
  )

immich-go upload from-folder --recursive \
  --server "$IMMICH_URL" \
  --api-key "$IMMICH_API_KEY" \
  --pause-immich-jobs=FALSE \
  "${UPLOAD_DIRS[@]}"
