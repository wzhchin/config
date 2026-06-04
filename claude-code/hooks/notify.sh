#!/bin/bash
# Notification hook: send OSC 99 desktop notifications for Claude Code events.
# Usage: notify.sh <event-type>
#   Events: stop, stop-failure, permission, notification, task-completed, dismiss
set -euo pipefail

event="${1:-stop}"
input=$(cat)

case "$event" in
  stop)
    title="Claude Code - Done"
    body="Response finished"
    ;;
  stop-failure)
    err=$(jq -r '.error // .error_type // "unknown"' <<<"$input" 2>/dev/null || echo "unknown")
    title="Claude Code - Error"
    body="API error: ${err}"
    ;;
  permission)
    title="Claude Code - Input Needed"
    body="Awaiting user response"
    ;;
  notification)
    ntype=$(jq -r '.notification_type // .type // "unknown"' <<<"$input" 2>/dev/null || echo "unknown")
    title="Claude Code - Notification"
    body="${ntype}"
    ;;
  task-completed)
    subject=$(jq -r '.subject // .task_subject // "Unknown task"' <<<"$input" 2>/dev/null || echo "Unknown task")
    title="Claude Code - Task Done"
    body="${subject}"
    ;;
  dismiss)
    seq=""
    for id in claude-stop claude-stop-failure claude-permission claude-notification claude-task-completed; do
      seq="${seq}$(printf '\033]99;i=%s:p=close;\033\\' "$id")"
    done
    jq -nc --arg seq "$seq" '{terminalSequence: $seq}'
    exit 0
    ;;
  *)
    exit 0
    ;;
esac

# OSC 99: title chunk (d=0) + body chunk (d=1 default), w=0 = never expire
id="claude-${event}"
seq=$(printf '\033]99;i=%s:w=0:d=0;%s\033\\' "$id" "$title")
seq="${seq}$(printf '\033]99;i=%s:p=body;%s\033\\' "$id" "$body")"

jq -nc --arg seq "$seq" '{terminalSequence: $seq}'
