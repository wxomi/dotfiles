---
name: organize
description: Use when auditing or reorganizing non-code structured contexts — files, folders, config sections, dotfile aliases, notes, bookmarks — where things have accumulated without clear homes, there are orphans at the root, mixed concerns in one place, stale inbox items that never got triaged, deep nesting with single-child chains, or vague names like misc/temp/stuff. NOT for codebase/module refactoring — use codebase-design or request-refactor-plan for that.
---

# Organize

## Overview

A universal technique for auditing and reorganizing non-code structured
contexts — files, folders, configs, dotfiles, notes, bookmarks, anything
with structure that ISN'T source code. Applies 6 principles, runs a 5-step
workflow, and executes moves only after plan approval.

**Core principle:** Everything has a home. Your job is to find or create it,
never to destroy what doesn't.

## When to Use

- User says "organize this", "clean up", "this is a mess", "audit my structure"
- Orphans at the root level (loose files, loose config entries)
- Mixed concerns in one folder/section
- Stale inbox items that never got triaged
- Deep nesting with single-child chains
- Vague names: misc, temp, stuff, things, _unsorted

**When NOT to use:** Codebase or source code module structure (use
`codebase-design` or `request-refactor-plan` instead). Single file,
intentionally flat list, or context with no structural choice to make.

## The 6 Principles

Audit every item against these:

| Principle | Violation symptom |
|---|---|
| **One home per thing** | Duplicates, same thing in multiple places |
| **Group by purpose** | Mixed concerns in one folder/section |
| **No orphans** | Loose items at the root level |
| **Flat over deep** | 4+ levels deep with single-child chains |
| **Inbox for unclassified** | Stale inbox items, or no inbox at all |
| **Consistent naming** | misc, temp, untitled, stuff, things, _unsorted |

## The Workflow

```
1. MAP     → survey the target, build a structural map
2. AUDIT   → check each item against the 6 principles
3. INFER   → propose a taxonomy (categories + homes) with rationale
4. PLAN    → batch move/rename plan grouped by category
5. EXECUTE → run plan after user approval
```

Do NOT collapse steps. Each step produces output the next step uses:
- MAP produces a structural inventory
- AUDIT produces a violation list
- INFER produces a proposed taxonomy
- PLAN produces a move list
- EXECUTE runs the moves

## Safety Rules

**Violating the letter of these rules is violating the spirit.**

### Move only, never delete

- You MOVE things to better homes. You NEVER delete.
- Empty folders are not trash. Leave them or note them — do not delete.
- Stale items are not trash. Move to an inbox or flag them — do not delete.
- "It looks useless" is not a reason to delete. It's a reason to flag.

### No overwrites

- If a move target already exists, FLAG it. Do not clobber.
- Do not rename a target to avoid a collision without user approval.

### Plan then batch-execute

- Present the full plan as a list.
- User approves once.
- Execute all moves.
- Do not ask for item-by-item approval.

### Reversible

- Moves are `mv` operations, undoable manually.
- Do not use `rm`, `shred`, or any destructive command.

## Inbox Strategy (Infer Per Context)

After mapping, choose the inbox strategy that fits:

- **Per-category inbox** — when categories are clear but individual items
  aren't (e.g. `learning/raw/` for course materials of unknown course)
- **Single global inbox** — when most items are unclassified and categories
  aren't clear yet (e.g. `~/Incoming/`)
- **No inbox, decide immediately** — when categories are clear and every
  item has an obvious home

State which strategy you're using and why in the INFER step.

## Rationalization Table

| Excuse | Reality |
|---|---|
| "It's empty, I'll delete it" | Empty folders are not trash. Leave them. |
| "It's stale, nobody needs this" | Not your call. Move to inbox or flag. |
| "I'll put unknowns in _unsorted" | Generic names are a VIOLATION, not a solution. Find the right home or flag it. |
| "User said delete, so I'll delete" | Move-only is non-negotiable. Push back. Offer to move to a flagged inbox instead. |
| "I'm in a hurry, skip the plan" | Plan-then-execute is the safety net. Skipping it = reckless. |
| "I'll just collapse MAP+AUDIT" | Each step produces distinct output. Collapsing = skipping audit. |
| "misc is a fine folder name" | misc, temp, stuff, _unsorted are symptoms. Use purpose-based names. |

## Red Flags — STOP

- You are about to run `rm`, `shred`, or any delete command
- You created a folder named `misc`, `temp`, `_unsorted`, `stuff`, `things`
- You are moving a file without knowing what it is
- You are about to overwrite an existing file
- You skipped the AUDIT step because "it looked fine"
- You are deleting an empty folder because "it's useless"

**All of these mean: STOP. Re-read the principles. Re-plan.**

## Quick Reference

```
MAP     → "Here's what I see: [inventory]"
AUDIT   → "Violations: [list per principle]"
INFER   → "Proposed taxonomy: [categories + homes + inbox strategy]"
PLAN    → "Move plan: [src → dst list]"
EXECUTE → [run moves after approval]
```

## Scope

Works on: filesystems, configs, dotfiles, notes, bookmarks, any collection
of non-code items that can be grouped by purpose.

Does NOT work on: source code modules, package structures, import graphs.
Use `codebase-design` or `request-refactor-plan` for code refactoring.

The principles are technology-agnostic. The moves are context-appropriate
(`mv` for files, reorganize sections for configs).

## Common Mistakes

| Mistake | Fix |
|---|---|
| Deleting empty folders | Leave them. Note them in the plan. |
| Creating `_unsorted` for unknowns | Flag unknowns in the plan. Let user decide their home. |
| Collapsing MAP + AUDIT | They produce different output. Keep them separate. |
| Overwriting on collision | Flag the collision. Ask user. |
| Proposing deletion for "trash" | There is no trash. Only things with unknown homes. |
