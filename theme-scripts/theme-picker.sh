#!/usr/bin/env bash

SCRIPT_DIR="$HOME/.config/noctalia/theme-scripts"

CHOICE=$(printf "Third Impact\nLCL Deep Blue\nUnit-01" \
  | wofi --dmenu --prompt "Theme" --width 300 --height 180 --no-actions)

case "$CHOICE" in
  "Third Impact") bash "$SCRIPT_DIR/apply-third-impact.sh" ;;
  "LCL Deep Blue") bash "$SCRIPT_DIR/apply-lcl-deep-blue.sh" ;;
  "Unit-01")       bash "$SCRIPT_DIR/apply-unit-01.sh" ;;
esac
