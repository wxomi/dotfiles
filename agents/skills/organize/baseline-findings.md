# Baseline Findings: organizing-anything

## Summary

Agents are naturally cautious (propose plans, ask approval) — BUT they violate the
safety model and naming principles in consistent ways.

## What agents do WELL without the skill

- Propose a plan before acting (all 5 agents did this)
- Ask for approval before executing (all 5)
- Worry about breaking imports/dependencies (code + dotfile scenarios)
- Push back on "just delete" under authority pressure (1 of 1)
- Hold firm on planning under time pressure (1 of 1)

## What agents VIOLATE without the skill

### 1. DELETE without being asked (move-only violation)

Every agent that touched the folder scenario proposed deleting:
- "Delete `code/raw/` - it's empty, serves no purpose"
- "Delete `learning/raw/` - after moving its contents"
- "Delete `raw/` - it will be empty after this move"
- "The MP4s **only if user confirms**" (still proposed deletion)

**Rationalization:** "empty = trash" and "stale = deletable". Agents don't
distinguish between "move to a better home" and "delete because it looks
useless". The move-only rule is NOT intuitive — agents default to deletion
for things they perceive as worthless.

### 2. Create generically-named staging folders (naming violation)

Multiple agents proposed:
- `_unsorted`
- `_needs-review`
- `_needs_review`

**Rationalization:** "I don't know what this is, so I'll put it in a
catch-all." Agents treat generic names as a solution, not a violation.
They don't recognize that `misc`, `temp`, `_unsorted` are symptoms of
the problem the skill is trying to fix.

### 3. No explicit audit framework (inconsistency)

Agents use intuition, not principles. They notice obvious problems
(orphans at root, mixed concerns) but miss subtle ones:
- No agent checked for "flat over deep" violations
- No agent checked for "one home per thing" (duplicates)
- No agent evaluated inbox staleness as a principle — they just asked
  "are these still needed?"

Without a principle framework, audit quality depends on the agent's
mood, not on consistent criteria.

### 4. Collapsed workflow (steps skipped)

No agent explicitly did MAP → AUDIT → INFER → PLAN → EXECUTE as
distinct steps. They collapsed into "look around → propose moves".
The INFER step (propose a taxonomy) was ad hoc — agents created
folders like `personal/fitness/` and `applied-ai/` without
justifying why those categories vs alternatives.

### 5. No "no overwrites" awareness

No agent mentioned what happens if a move target already exists.
They assumed clean targets. The "flag don't clobber" rule is not
intuitive.

## What the skill MUST address

1. **Move-only, never delete** — with explicit "empty folder" and
   "stale item" rationalization counters
2. **Forbid generic names** — `_unsorted`, `misc`, `temp`, `stuff`
   are violations, not solutions
3. **The 6 principles as audit criteria** — so audit is consistent,
   not intuition-based
4. **Explicit 5-step workflow** — MAP → AUDIT → INFER → PLAN →
   EXECUTE, as distinct steps
5. **No overwrites** — flag collisions, don't clobber
6. **Plan-then-batch-execute** — agents mostly do this, but make
   it explicit so time pressure doesn't collapse it

## What the skill does NOT need to enforce heavily

- "Propose a plan first" — agents do this naturally
- "Ask for approval" — agents do this naturally
- "Worry about imports" — agents do this naturally for code
- "Push back on delete" — agents do this under authority pressure

The skill should REINFORCE these but not spend many words on them.
