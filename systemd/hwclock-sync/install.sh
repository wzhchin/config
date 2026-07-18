#!/usr/bin/env bash
# 安装 hwclock-sync systemd timer（每天 11:00：先 chrony 对时，再把系统时钟写回 RTC）
set -euo pipefail

if [[ $EUID -ne 0 ]]; then
    echo "需要 root 权限，正在用 sudo 重新执行..." >&2
    exec sudo -E bash "$0" "$@"
    exit 1
fi

SRC_DIR="$(cd "$(dirname "$0")" && pwd)"

# --- 1. 安装并配置 chrony（持续对时） ---
if ! pacman -Q chrony >/dev/null 2>&1; then
    echo ">>> 安装 chrony ..."
    pacman -S --needed --noconfirm chrony
fi

# 备份已有 chrony.conf，再安装国内源版本
CHRONY_CONF=/etc/chrony.conf
if [[ -f "$CHRONY_CONF" && ! -f "$CHRONY_CONF.bak" ]]; then
    cp -a "$CHRONY_CONF" "$CHRONY_CONF.bak"
    echo "已备份原 $CHRONY_CONF -> $CHRONY_CONF.bak"
fi
install -m 0644 "$SRC_DIR/chrony.conf" "$CHRONY_CONF"
echo "已安装 $CHRONY_CONF"
# 注意：采用一次性对时（chronyd -q），不启用 chronyd.service 守护进程

# --- 2. 安装 hwclock-sync units ---
DEST_DIR=/etc/systemd/system
for unit in hwclock-sync.service hwclock-sync.timer; do
    install -m 0644 "$SRC_DIR/$unit" "$DEST_DIR/$unit"
    echo "已安装 $DEST_DIR/$unit"
done

systemctl daemon-reload
systemctl enable --now hwclock-sync.timer

echo
echo "--- 一次性对时测试 ---"
chronyd -q || true
echo
echo "--- timer 计划运行时间 ---"
systemctl list-timers hwclock-sync.timer --no-pager || true
