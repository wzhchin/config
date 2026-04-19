#!/usr/bin/env bash

set -eu

~/bin/immich-go upload from-folder --recursive --server "$IMMICH_URL" --api-key "$IMMICH_API_KEY" --pause-immich-jobs=FALSE /sdcard/DCIM /sdcard/Pictures/QQ /sdcard/Pictures/WeiXin /sdcard/Pictures/Screenshots
