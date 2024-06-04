#!/bin/sh

if [ "$SENDER" = "display_change" ]; then
  sketchybar --set "$NAME" label="$INFO"
fi
