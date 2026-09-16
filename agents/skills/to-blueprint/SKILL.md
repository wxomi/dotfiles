---
name: to-blueprint
description: Turn the decisions you've already settled into a build blueprint — structure, names, logic — and confirm it before any code is written.
disable-model-invocation: true
---

# To Blueprint

A **blueprint** is the drawing both sides sign off before construction: what each piece is **called**, where it **sits**, and what it **does**. It catches the mismatch between your head and the agent's while the mismatch is still one line of markdown rather than a diff.

Run it after the interview (`/grill-with-docs`, `/grill-me`) and before `/to-spec` or `/implement`. Work from what's already in the conversation — this is synthesis, not another interview.

The blueprint stops at **signatures**: paths, names, types, and control flow in prose. Bodies belong to `/implement`.

## Process

### 1. Harvest the conventions

Facts are your job, so read before you draw: the code the change will actually touch, plus `CONTEXT.md` and any ADRs covering that area. Harvest from the code rather than from habit —

- the naming patterns in use: casing, file naming, suffixes, event and column naming
- where a file of each kind lives: module, test, type, fixture, migration, config
- the **prior art** — the closest existing module to the one being built

Complete when you can name the specific file you are modelling the new work on. Where the codebase disagrees with itself, present the competing conventions and let the user pick.

### 2. Draw the three passes

Present one pass at a time and wait for a response before the next. They run in dependency order: a name argued over once the structure is settled is cheap, and the reverse is not.

**Pass 1 — Structure.** The modules, the **seam** each one presents, and the concrete file paths: files added, files modified, files deleted. Say which existing seams you're reusing and which are new, and for each new one, what varies across it. Reach for `/codebase-design` for the vocabulary — module, interface, depth, seam, adapter — rather than inventing terms here.

**Pass 2 — Names.** Every name the change introduces, in one list: modules, files, types, functions, fields, events, columns, flags, test names. Beside each, the glossary term it descends from. A name with no term behind it is a **new domain term** — surface it as such and settle it with `/domain-modeling`, so it enters the vocabulary deliberately instead of arriving inside a diff.

**Pass 3 — Logic.** For each nontrivial module: its signature, then the control flow as numbered prose — inputs, branches, error modes, ordering constraints, invariants that must hold, and what stays hidden inside. Where prose is genuinely less precise than a snippet — a state machine, a reducer, a schema, a type shape — inline the snippet and keep it to the decision-rich part.

Write every plan item as a **checkbox**, grouped per file in dependency order (schema before entity before controller). The blueprint is then the run's progress surface: `/implement` ticks each box as it lands, so at a glance you see what's built, what's in flight, and what's untouched.

Each pass is complete when the user has confirmed it and every name in pass 2 traces to a glossary term or to an explicit decision to add one.

### 3. Lint for the unspecified

A gap you filled silently is a gap you'll discover as a diff. So run over the blueprint as if **inspecting** it, and raise each place the conversation left open as a **warning against the specific line it undermines** — `Double-booking error UX is unspecified` beside the criterion that assumes one.

Offer each warning as a short menu of **concrete named options**, then two standing ones:

- *Let the agent decide* — an explicit delegation, which closes the gap as surely as choosing.
- *Describe a different fix* — the escape hatch for when none of the options is what they meant.

A menu beats an open question: it shows you'd already thought it through, and it's answerable in a word. Record each resolution under **Decisions** in the blueprint, with the option chosen and the ones rejected, so a later reader sees the fork rather than just the outcome.

Every warning ends in a chosen option — an unanswered one keeps the blueprint open. Silence is not delegation; *Let the agent decide* has to be said.

### 4. Capture, then hand off

Write the agreed blueprint to `.scratch/<feature-slug>/BLUEPRINT.md`: the three passes under their own headings, the plan as checkboxes, and **Decisions** last.

This file is where file paths and signatures are allowed to live — `/to-spec` and `/to-tickets` exclude them precisely because they go stale. The blueprint carries them because it's read while the work is being built and then stops being read: `/implement` ticks its boxes as it goes, and once the code exists the code is the truth. Point at the blueprint from the spec or ticket rather than copying it in.

Then rejoin the flow: `/to-spec` for a multi-session build, or `/implement` for work that fits in one window.
