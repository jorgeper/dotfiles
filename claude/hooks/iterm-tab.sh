#!/bin/bash
# Set the iTerm2 tab color to reflect Claude Code's state.
# Usage: iterm-tab.sh alive|working|idle|waiting|off
# Called from hooks in ~/.claude/settings.json. Writes straight to the
# terminal because hook stdout goes to Claude, not the screen.

case "$1" in
  alive|idle) rgb=(214 122 58)  ;;   # orange: Claude lives here, ready for you
  working)    rgb=(250 200 40)  ;;   # yellow: chewing on a turn, leave it
  waiting)    rgb=(225 60 80)   ;;   # red: blocked on a permission or question
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

{ printf "%s" "$seq" > /dev/tty; } 2>/dev/null
exit 0
