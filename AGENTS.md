# Agent instructions

This file is the shared startup contract for coding agents. Keep it under 150 lines.
Do not append task history, test receipts or superseded rules here; route to a
document instead. `CLAUDE.md` imports only this file.

## Load only what the task needs

Before changing a subsystem, read its row. Do not bulk-read `.ai/` at startup.

| Task                                        | Read before changes                                      |
| ------------------------------------------- | -------------------------------------------------------- |
| Where code goes, new modules or services    | `.ai/specs/architecture.md`                              |
| UI components, stories, UI state            | `.ai/specs/ui.md`                                        |
| Writing or running tests                    | `.ai/guides/testing.md`                                  |
| Any Studio or MCP work, upload or import    | `.ai/guides/studio.md`, even if no local file is touched |
| Tools, Wally packages, internal libraries   | `docs/dependency-management.md`                          |
| Why something is the way it is              | Search `.ai/decisions.md`                                |
| Anything else, or where to record new facts | `.ai/README.md`                                          |

## Project rules

- Luau only: Rojo sync, Wally packages, Rokit-pinned tools, Lune scripts. There is
  no Node.js or compile step. Run commands from the repository root.
- `default.project.json` defines sync ownership. `src/`, `libraries/` and the Wally
  package folders are filesystem-owned: edit them on disk, never in Studio.
  Everything else in the place is Studio-owned and Rojo leaves it alone.
- Entry scripts end in `.server.luau` or `.client.luau`; everything else is a
  module. Source is type-checked in strict mode.
- Services take their dependencies as arguments and pure logic lives in
  `src/shared`, so both can be tested offline. See `.ai/specs/architecture.md`.
- Do not update tools or dependencies incidentally, and never edit `Packages/`,
  `ServerPackages/` or `wally.lock` by hand. Run `lune run install` after a
  deliberate manifest change.
- Server code owns authoritative state and validates every client request.
  Secrets and server-only packages stay out of `ReplicatedStorage`.

## Verification

- Inspect `git status` and the relevant files before editing; preserve unrelated
  changes. Do not commit, push or publish unless asked.
- Run `lune run check` after code changes. It formats-checks, lints, type-checks
  and runs the offline tests. Documentation-only changes need no build.
- Offline tests are not evidence of Studio rendering, input, replication or
  persistence. Say which of those were and were not verified.
- Assume a sync session may already be running: do not start `lune run dev` or
  `rojo serve` unless asked.

## Keeping context small

- New evidence goes in a dated file under `.ai/audits/`, substantial choices in
  `.ai/decisions.md`, lasting contracts in `.ai/specs/`, procedures in
  `.ai/guides/`. Add a routing row above when a new document should be found.
- `.claude/rules/*.md` are short path-scoped reminders. Keep their `paths`
  frontmatter; an unscoped rule loads on every start.
