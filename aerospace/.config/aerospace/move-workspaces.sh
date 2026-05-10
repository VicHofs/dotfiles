#!/bin/bash

set -euo pipefail

local_config="$HOME/.config/secrets/aerospace.env"
if [ -f "$local_config" ]; then
  # Optional local overrides: BROWSER_MONITOR, CHAT_MONITOR, TERMINAL_MONITOR.
  # shellcheck disable=SC1090
  . "$local_config"
fi

monitor_ids() {
  aerospace list-monitors --format '%{monitor-id}'
}

first_monitor() {
  monitor_ids | sed -n '1p'
}

second_monitor() {
  monitor_ids | sed -n '2p'
}

third_monitor() {
  monitor_ids | sed -n '3p'
}

last_monitor() {
  monitor_ids | tail -n 1
}

monitor_count() {
  monitor_ids | wc -l | tr -d ' '
}

count="$(monitor_count)"
primary="$(first_monitor)"

case "$count" in
  0)
    exit 0
    ;;
  1)
    default_terminal="$primary"
    default_browser="$primary"
    default_chat="$primary"
    ;;
  2)
    default_terminal="$primary"
    default_browser="$(last_monitor)"
    default_chat="$(last_monitor)"
    ;;
  *)
    default_terminal="$primary"
    default_browser="$(second_monitor)"
    default_chat="$(third_monitor)"
    ;;
esac

terminal_monitor="${TERMINAL_MONITOR:-$default_terminal}"
browser_monitor="${BROWSER_MONITOR:-$default_browser}"
chat_monitor="${CHAT_MONITOR:-$default_chat}"

move_workspace() {
  workspace="$1"
  monitor="$2"

  if [ -n "$monitor" ]; then
    aerospace move-workspace-to-monitor --workspace "$workspace" "$monitor" >/dev/null 2>&1 || true
  fi
}

case "${1:-all}" in
  browser)
    move_workspace B "$browser_monitor"
    ;;
  chat)
    move_workspace C "$chat_monitor"
    ;;
  terminal)
    move_workspace T "$terminal_monitor"
    ;;
  all)
    move_workspace B "$browser_monitor"
    move_workspace C "$chat_monitor"
    move_workspace T "$terminal_monitor"
    ;;
  *)
    printf 'Unknown workspace role: %s\n' "$1" >&2
    exit 1
    ;;
esac
