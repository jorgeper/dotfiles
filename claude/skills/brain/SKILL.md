---
name: brain
description: Use when the user asks to record, capture, save, or jot something into their brain, second brain, brain vault, or devlog — e.g. "add this to my devlog", "capture this in my brain", "note this down in my second brain", "record what we just discussed".
---

# Brain

Capture notes into Jorge's Obsidian vault. The vault is at `/Users/jorgeper/src/brain` — **fixed, never scan for it, never ask where it is.**

## Two modes

Pick by what the user says:

| User says | Mode |
|---|---|
| "devlog" anywhere in the request | **Devlog entry** — prepend to the single devlog file |
| otherwise ("note", "capture", "brain") | **Standalone note** — new dated file |

## Mode 1: Devlog entry

Prepend an entry to the top of the single file `/Users/jorgeper/src/brain/devlog/devlog.md` (create the file if it doesn't exist).

Entry format — date + short topic title header, then content:

```markdown
## 2026-07-26 — Git worktrees share one .git

Learned that all worktrees of a repo point at a single shared `.git`
database, so commits in any worktree are instantly visible in the others.
```

Prepend means: Read the file, then Write it back as `new entry + blank line + existing content`. Newest entry is always at the top. Never append to the bottom, never edit or delete existing entries.

## Mode 2: Standalone note

Create a new file: `/Users/jorgeper/src/brain/devlog/YYYY-MM-DD <short topic>.md` (spaces in the filename, today's date).

Match the conventions of existing files in that folder:

```markdown
---
tags: [topic1, devlog]
date: YYYY-MM-DD
tldr: One-sentence summary of the note.
---

# Title

Content…
```

Link related vault notes with `[[wiki links]]`. Mermaid diagrams are fine (Obsidian renders them).

## Content rules

- Write down what the user said or what was discussed — concise, no padding. If capturing a conversation, keep the user's questions and the answers.
- Infer sensible `tags` and title from the content; don't ask.
- Never write to `manual/`, `ai/`, or `raw/` — those folders belong to the user. All captures go to the devlog paths above.
- Never edit or delete existing notes other than prepending to `devlog.md` as described.
