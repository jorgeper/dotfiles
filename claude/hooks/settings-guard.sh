#!/bin/bash
# Keep ~/.claude/settings.json a symlink into the dotfiles repo, and commit
# the repo whenever Claude Code rewrites the file (/model, /config, plugins).
# Runs from the ConfigChange and SessionStart hooks. Idempotent and quiet
# unless it had to repair the link.

REPO="$HOME/src/dotfiles"
TARGET="$REPO/claude/settings.json"
LINK="$HOME/.claude/settings.json"
msg=""

if [ -f "$LINK" ] && [ ! -L "$LINK" ]; then
  # Claude Code replaced the symlink with a plain file. Its content is the
  # newest, so adopt it into the repo and put the link back.
  mv -f "$LINK" "$TARGET" && ln -s "$TARGET" "$LINK"
  msg="settings.json had become a plain file; moved it back into dotfiles and re-linked."
fi

if git -C "$REPO" diff --quiet -- claude/settings.json 2>/dev/null; then
  : # nothing to commit
else
  git -C "$REPO" add claude/settings.json
  git -C "$REPO" commit -q -m "chore(claude): settings.json updated by Claude Code" -- claude/settings.json \
    && msg="${msg:+$msg }Committed settings.json to dotfiles."
fi

[ -n "$msg" ] && printf '{"systemMessage":"%s"}\n' "$msg"
exit 0
