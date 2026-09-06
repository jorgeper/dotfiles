---
name: d2-diagrams
description: Use when adding a diagram to an Obsidian note or markdown doc — architecture, pipeline, flow, or system sketches — or when the user asks for a d2/diagram code block.
---

# D2 Diagrams — fit the page

Diagrams for this user's Obsidian vault are D2 code blocks (```d2 fences). The vault's D2 plugin renders them inline with `elk` layout and sketch mode.

**The one constraint that matters: never wider than the page.** Notes are ~1100px wide and scroll vertically. A too-wide diagram either forces left-right scrolling or gets shrunk until labels are unreadable. Height is cheap; width is not.

## The output shape

Every diagram is:

1. **Rendered width ≤ the width budget.** The budget is 1100px unless the user names one ("keep it under 800px", "about 1200 wide" → that number). This is the acceptance test, checked with the CLI (below). Reduce width through the structure techniques in rule 3, not by shrinking boxes.
2. **Direction by flow length**: main flow has ≤4 boxes → `direction: right`; longer → `direction: down` (a readable column beats a shrunken band). State the direction explicitly on the first line either way.
3. **Boxes hug their text — never set explicit `width`/`height` on nodes.** Oversized boxes ("chubby": big empty padding around a short label) are a rejected style. Compactness comes from structure instead:
   - **Cut minor nodes entirely** — implementation details (config files, storage paths) go in the note's prose, not the diagram. Fewer nodes beats cleverer layout.
   - Containers are for grouping 2+ children. A container around ONE child is a puffy box — flatten it or cut the child.
   - In `direction: down`, container children **without an inner edge** sit side by side — use this to widen/shorten containers.
   - **Drop edge labels that restate the obvious** — each label inflates the gap between layers.
   - **Avoid `grid-rows`/`grid-columns` for the main layout**: D2 grids stretch cells to align rows/columns even when nodes have explicit sizes, which is where chubby boxes come from. Accept a moderate portrait shape (~1:2) over a stretched grid.
   Per-container `direction` does NOT work with elk/dagre — don't try phase-containers.
4. **≤2 levels**: top-level nodes/containers plus at most one level of children. A container never contains another container.
5. **Short labels**: ≤4 words per node; no `\n`. Explanations belong in the note's prose.
6. **Repetition collapsed**: N identical parallel things (workers, sandboxes, shards) are ONE node labeled `× N`, not N copies.
7. **≤12 nodes total.** More: split into two diagrams under separate headings.

## Verify before embedding (required)

```bash
d2 --layout elk --sketch note-diagram.d2 /tmp/out.svg
grep -o 'viewBox="[^"]*"' /tmp/out.svg | head -1   # 3rd number = width
```

Width > budget → restructure (switch to `direction: down`, nest nodes into their parent box, collapse nodes, shorten labels) and re-render. Do not embed an over-wide diagram. Never fix width or balance by setting explicit node sizes — that makes chubby boxes.

## Quick syntax

```d2
direction: down
a: "Label" { shape: cylinder }
box: "Container" {
  child1
  child2
}
a -> box.child1: "verb"
box -> c: "verb"        # edges to containers are fine in D2
```

Useful shapes: `cylinder` (storage), `page` (docs/issues), `diamond` (decision), `person`. Default rectangle otherwise.

## Common mistakes

| Mistake | Fix |
|---|---|
| Long pipeline as `direction: right` | 5+ steps left-to-right blows past page width; go `down` |
| Omitting `direction` | Layout is luck; state it explicitly |
| Deep nesting (box-in-box-in-box) | Flatten to one container level; relate the rest with edges |
| One node per parallel worker | One node, `× N` label |
| Paragraph-long labels | Move to note prose |
