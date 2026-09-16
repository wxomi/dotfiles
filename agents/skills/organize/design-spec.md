# Design Spec: organizing-anything skill

## Identity

- **Name:** `organizing-anything`
- **Type:** Technique (concrete method with steps)
- **Description:** Use when auditing or reorganizing any structured context — files, folders, code modules, config sections, dotfile aliases, notes — where things have accumulated without clear homes, there are orphans at the root, mixed concerns, or stale inbox items that never got triaged

## The 6 Principles

| Principle | What it means | Violation symptom |
|---|---|---|
| One home per thing | Everything has a canonical location | Duplicates, things in multiple places |
| Group by purpose | Related things live together; unrelated separate | Mixed concerns in one folder/section |
| No orphans | Nothing loose at the root level | Loose files/items at top level |
| Flat over deep | Shallow structure; nest only when it aids finding | 4+ levels deep with single-child chains |
| Inbox for unclassified | Staging area for unclear items, with a triage path out | Stale inbox items, no inbox at all |
| Consistent naming | Predictable, scannable names | misc, temp, untitled, stuff, things |

## Audit Workflow

1. MAP — agent surveys the target context, builds a structural map
2. AUDIT — checks each item against the 6 principles, lists violations
3. INFER — proposes a taxonomy for this context (categories + homes)
4. PLAN — produces a batch move/rename plan grouped by category
5. EXECUTE — runs the plan after user approval (moves only, never deletes)

Inbox strategy is inferred per context (per-category inbox, single global inbox, or decide-immediately) based on volume of unclassified items and clarity of categories.

## Safety Model

- Move only, never delete. Unclear items stay put and get flagged.
- Plan-then-batch-execute. User approves once, agent runs all moves.
- No overwrites. If target exists, agent flags it.
- Reversible. Moves are mv operations, undoable manually.

## Scope

Applies to: filesystems, code modules, configs, notes, bookmarks, any collection of items that can be grouped.

Does NOT apply to: things with no structural choice (single file, intentionally flat list).

## What It Is NOT

- Not a file-watching daemon (on-demand only)
- Not a naming-convention enforcer (suggests names, doesn't hardcode)
- Not a duplicate finder (mechanical, use a tool)
- Not a backup system (moves are reversible but no snapshot)
