#!/bin/sh

# The $SELECTED variable is available for space components and indicates if
# the space invoking this script (with name: $NAME) is currently selected:
# https://felixkratz.github.io/SketchyBar/config/components#space----associate-mission-control-spaces-with-an-item

FONT=Regular

if [[ "$SELECTED" = true ]]; then
  FONT=Bold
fi

# sketchybar --set "$NAME" background.drawing="$SELECTED"
sketchybar --set "$NAME" \
    background.drawing="$SELECTED" \
    icon.font.style="$FONT" \
    icon.highlight="$SELECTED"
