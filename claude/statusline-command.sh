#!/bin/bash
# Claude Code status line.
# Reads the JSON payload Claude Code sends on stdin and prints a single
# line, in a muted/pastel-ish 256-color palette, with: model name,
# current directory, git branch (if any), context-window usage, and
# plan rate-limit usage (5-hour session window + 7-day weekly window),
# each rendered as a compact block-character progress bar.

input=$(cat)

model=$(printf '%s' "$input" | jq -r '.model.display_name')
cwd=$(printf '%s' "$input" | jq -r '.workspace.current_dir')
used=$(printf '%s' "$input" | jq -r '.context_window.used_percentage // empty')
five_hour=$(printf '%s' "$input" | jq -r '.rate_limits.five_hour.used_percentage // empty')
seven_day=$(printf '%s' "$input" | jq -r '.rate_limits.seven_day.used_percentage // empty')

# Shorten $HOME to ~ for a compact directory display.
dir=${cwd/#$HOME/\~}

# Git branch + dirty marker. --no-optional-locks avoids blocking on/holding
# git's lock file while Claude Code is also using the repo.
branch=""
dirty=""
if git --no-optional-locks -C "$cwd" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  branch=$(git --no-optional-locks -C "$cwd" branch --show-current 2>/dev/null)
  if [ -n "$(git --no-optional-locks -C "$cwd" status --porcelain 2>/dev/null)" ]; then
    dirty="*"
  fi
fi

# Muted, mid-tone 256-color palette (soft/pastel-ish, gruvbox/nord-leaning;
# no neon brights, no dim codes). Bold is used only on the model name as
# the anchor of the line; everything else stays plain for a calmer look.
RESET="\033[0m"
SEP_COLOR="\033[38;5;240m"     # subtle muted gray, for separators
MODEL_COLOR="\033[1;38;5;73m"  # soft teal/cyan (slightly bold for emphasis)
DIR_COLOR="\033[38;5;110m"     # muted sky blue
GIT_COLOR="\033[38;5;180m"     # soft amber/tan
LABEL_COLOR="\033[38;5;246m"   # soft gray, for "ctx"/"5h"/"wk" labels
GREEN="\033[38;5;108m"         # soft sage/sea green   (<60%, OK)
YELLOW="\033[38;5;179m"        # soft amber/gold       (60-79%, warning)
RED="\033[38;5;167m"           # soft red/rose         (>=80%, critical)

SEP=" ${SEP_COLOR}›${RESET} "

# color_for_pct <0-100> -> prints the ANSI color for that threshold.
color_for_pct() {
  local pct=$1
  if [ "$pct" -ge 80 ]; then
    printf '%s' "$RED"
  elif [ "$pct" -ge 60 ]; then
    printf '%s' "$YELLOW"
  else
    printf '%s' "$GREEN"
  fi
}

# make_bar <0-100> <cells> -> prints a filled/empty block-character bar.
make_bar() {
  local pct=$1 len=$2 filled empty i bar
  filled=$(( (pct * len + 50) / 100 ))
  [ "$filled" -gt "$len" ] && filled=$len
  [ "$filled" -lt 0 ] && filled=0
  empty=$((len - filled))
  bar=""
  for ((i = 0; i < filled; i++)); do bar="${bar}█"; done
  for ((i = 0; i < empty; i++)); do bar="${bar}░"; done
  printf '%s' "$bar"
}

line="${MODEL_COLOR}◆ ${model}${RESET}"
line="${line}${SEP}${DIR_COLOR}${dir}${RESET}"

if [ -n "$branch" ]; then
  line="${line}${SEP}${GIT_COLOR}⎇ ${branch}${dirty}${RESET}"
fi

BAR_LEN=6

if [ -n "$used" ]; then
  used_int=$(printf '%.0f' "$used")
  ctx_color=$(color_for_pct "$used_int")
  ctx_bar=$(make_bar "$used_int" "$BAR_LEN")
  line="${line}${SEP}${LABEL_COLOR}ctx${RESET} ${ctx_color}${ctx_bar} ${used_int}%${RESET}"
fi

# Claude.ai/Claude Code plan usage limits (mirrors the /usage screen):
# 5-hour session window and 7-day (weekly, all models) window. Either or
# both may be absent (e.g. not a subscription plan, or no API response yet),
# in which case that piece is simply omitted.
usage_parts=""
if [ -n "$five_hour" ]; then
  five_int=$(printf '%.0f' "$five_hour")
  five_color=$(color_for_pct "$five_int")
  five_bar=$(make_bar "$five_int" "$BAR_LEN")
  usage_parts="${LABEL_COLOR}5h${RESET} ${five_color}${five_bar} ${five_int}%${RESET}"
fi
if [ -n "$seven_day" ]; then
  week_int=$(printf '%.0f' "$seven_day")
  week_color=$(color_for_pct "$week_int")
  week_bar=$(make_bar "$week_int" "$BAR_LEN")
  week_part="${LABEL_COLOR}wk${RESET} ${week_color}${week_bar} ${week_int}%${RESET}"
  if [ -n "$usage_parts" ]; then
    usage_parts="${usage_parts} ${SEP_COLOR}·${RESET} ${week_part}"
  else
    usage_parts="$week_part"
  fi
fi
if [ -n "$usage_parts" ]; then
  line="${line}${SEP}${usage_parts}"
fi

printf "%b" "$line"
