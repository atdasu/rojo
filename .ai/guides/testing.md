# Offline tests

Tests are Lune scripts in `tests/*.luau`. They require modules straight from
`../src` or `../libraries` and run without Roblox Studio.

```powershell
lune run test            # every test
lune run test lifetime   # tests/lifetime.luau only
```

Each file runs in its own process. A test passes when it exits normally and fails
when it throws, so use `assert(condition, "what should be true")`.

## Writing a test

1. Require the module with a relative path: `require("../src/shared/Math/Curve")`.
2. Build hand-made fakes for whatever the module receives. A fake is a plain table
   with only the members the module uses. See `tests/lifetime.luau` for a fake
   signal and `tests/reactive-state.luau` for a fake Vide.
3. Assert on results and on the fakes.
4. End with one `print("PASS: <name>")` line.

## What can be tested offline

A module is testable when requiring it does not touch `game`, `script` or
`workspace`. That is why services take their dependencies as arguments and pure
logic lives in `src/shared`; see `.ai/specs/architecture.md`. If a module is hard
to test, move its logic into a pure function and keep the Roblox calls in a thin
caller.

`@lune/roblox` can build real datatypes (`Vector3`, `CFrame`) and read `.rbxm`
files when a test needs them.

## Limits

Offline tests prove logic only. They do not exercise rendering, input,
replication, physics or DataStores. Verify those in a Studio playtest and report
them separately.
