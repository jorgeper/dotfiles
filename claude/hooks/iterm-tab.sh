#!/bin/bash
# Set the iTerm2 tab color to reflect Claude Code's state.
# Usage: iterm-tab.sh alive|working|idle|waiting|off
# Called from hooks in ~/.claude/settings.json. Hook stdout goes to Claude,
# not the screen, and the hook process has no controlling terminal, so we
# find the tty of the parent Claude process and write to that device.

case "$1" in
  # Warm pastels derived from Gruvbox dark, softened toward its cream fg (#ebdbb2).
  alive|idle) rgb=(232 160 90)  ;;   # pastel orange #e8a05a: Claude lives here, ready for you
  working)    rgb=(242 211 138) ;;   # pale gold     #f2d38a: chewing on a turn, leave it
  waiting)    rgb=(240 120 104) ;;   # salmon        #f07868: blocked on a permission or question
  off)        seq=$'\e]6;1;bg;*;default\a' ;;
  *)          exit 0 ;;
esac

if [ -z "$seq" ]; then
  seq=$(printf '\e]6;1;bg;red;brightness;%s\a\e]6;1;bg;green;brightness;%s\a\e]6;1;bg;blue;brightness;%s\a' \
        "${rgb[0]}" "${rgb[1]}" "${rgb[2]}")
fi

# Inside tmux the sequence must be wrapped so it reaches the outer terminal.
if [ -n "$TMUX" ]; then
  seq=$(printf '\ePtmux;%s\e\\' "${seq//$'\e'/$'\e\e'}")
fi

# Resolve the terminal: the parent's tty (Claude Code), else our own.
ptty=$(ps -o tty= -p "$PPID" 2>/dev/null | tr -d ' ')
if [ -n "$ptty" ] && [ "$ptty" != "??" ] && [ -w "/dev/$ptty" ]; then
  dev="/dev/$ptty"
else
  dev=/dev/tty
fi

{ printf '%s' "$seq" > "$dev"; } 2>/dev/null
exit 0
