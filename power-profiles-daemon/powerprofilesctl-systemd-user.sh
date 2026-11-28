#!/usr/bin/env bash
set -euo pipefail

unit=powerprofilesctl-auto-switch.service
unit_dir="${XDG_CONFIG_HOME:-$HOME/.config}/systemd/user"
watcher="$unit_dir/powerprofilesctl-systemd-user.sh"

case "${1:-}" in
    on)
        mkdir -p "$unit_dir"
        if [[ ! "${BASH_SOURCE[0]}" -ef "$watcher" ]]; then
            install -m 755 -- "${BASH_SOURCE[0]}" "$watcher"
        fi
        cat > "$unit_dir/$unit" <<'UNIT'
[Unit]
Description=Switch power profiles on AC or battery power

[Service]
ExecStart=/usr/bin/bash "%E/systemd/user/powerprofilesctl-systemd-user.sh" watch
Restart=always
RestartSec=3s

[Install]
WantedBy=default.target
UNIT
        systemctl --user daemon-reload
        systemctl --user enable --now "$unit"
        ;;
    off)
        systemctl --user disable --now "$unit"
        ;;
    watch)
        export LC_ALL=C
        last_profile=
        while IFS= read -r line; do
            case "$line" in
                "The name org.freedesktop.UPower is owned by "*|*"PropertiesChanged"*"'OnBattery'"*) ;;
                *) continue ;;
            esac

            on_battery=$(gdbus call --system --dest org.freedesktop.UPower \
                --object-path /org/freedesktop/UPower \
                --method org.freedesktop.DBus.Properties.Get org.freedesktop.UPower OnBattery)
            case "$on_battery" in
                '(<true>,)') profile=power-saver ;;
                '(<false>,)') profile=performance ;;
                *) continue ;;
            esac

            if [[ "$profile" != "$last_profile" ]]; then
                powerprofilesctl set "$profile"
                last_profile="$profile"
            fi
        done < <(stdbuf -oL gdbus monitor --system --dest org.freedesktop.UPower \
            --object-path /org/freedesktop/UPower)
        ;;
    *)
        printf '用法：%s {on|off}\n' "${0##*/}" >&2
        exit 2
        ;;
esac
