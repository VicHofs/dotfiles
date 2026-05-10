#!/bin/bash

set -euo pipefail

focused_ws="$(aerospace list-workspaces --focused)"

local_config="$HOME/.config/secrets/aerospace.env"
if [ -f "$local_config" ]; then
  # Optional local overrides: BROWSER_MONITOR and TERMINAL_MONITOR.
  # shellcheck disable=SC1090
  . "$local_config"
fi

monitor_ids() {
  aerospace list-monitors --format '%{monitor-id}'
}

first_monitor() {
  monitor_ids | sed -n '1p'
}

last_monitor() {
  monitor_ids | tail -n 1
}

monitor_count() {
  monitor_ids | wc -l | tr -d ' '
}

count="$(monitor_count)"
primary="$(first_monitor)"

if [ "$count" -le 1 ]; then
  exit 0
fi

terminal_monitor="${TERMINAL_MONITOR:-$primary}"
browser_monitor="${BROWSER_MONITOR:-$(last_monitor)}"

b_monitor="$({ aerospace list-workspaces --all --format '%{workspace} %{monitor-id}' | while read -r ws mon; do
  if [ "$ws" = "B" ]; then
    printf '%s' "$mon"
    break
  fi
done; } )"

if [ "$b_monitor" = "$browser_monitor" ]; then
  aerospace move-workspace-to-monitor --workspace B "$terminal_monitor" >/dev/null 2>&1 || true
  aerospace move-workspace-to-monitor --workspace T "$browser_monitor" >/dev/null 2>&1 || true
else
  aerospace move-workspace-to-monitor --workspace T "$terminal_monitor" >/dev/null 2>&1 || true
  aerospace move-workspace-to-monitor --workspace B "$browser_monitor" >/dev/null 2>&1 || true
fi

aerospace workspace "$focused_ws" >/dev/null 2>&1 || true
