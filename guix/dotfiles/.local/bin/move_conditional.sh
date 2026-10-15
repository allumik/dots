#!/usr/bin/env bash
direction="$1"
is_floating=$(niri msg --json focused-window | jq '.is_floating')

if [ "$is_floating" = "true" ]; then
  niri msg action "move-window-to-workspace-${direction}"
else
  niri msg action "move-window-${direction}-or-to-workspace-${direction}"
fi
