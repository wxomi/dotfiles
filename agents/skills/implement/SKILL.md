---
name: implement
description: "Implement a piece of work based on a spec or set of tickets."
disable-model-invocation: true
---

Implement the work described by the user in the spec or tickets.

If a `BLUEPRINT.md` is pointed at from the spec or ticket, read it first — it holds the agreed paths, names and signatures that the spec deliberately leaves out. Tick each of its checkboxes as that item lands, so the blueprint tracks the run. Where the code has to depart from the blueprint, say so and get agreement before writing it that way.

Use /tdd where possible, at pre-agreed seams.

Run typechecking regularly, single test files regularly, and the full test suite once at the end.

Once done, use /code-review to review the work.

Commit your work to the current branch.
