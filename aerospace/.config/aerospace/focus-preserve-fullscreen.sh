#!/bin/bash

set -euo pipefail

direction="${1:?direction is required}"

was_fullscreen="false"
if focused_state="$(aerospace list-windows --focused --format '%{window-is-fullscreen}' 2>/dev/null)"; then
  was_fullscreen="$focused_state"
fi

aerospace focus "$direction"

if [ "$was_fullscreen" = "true" ]; then
  aerospace fullscreen
fi
