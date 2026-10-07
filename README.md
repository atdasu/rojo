# StarterGame

[![CI](https://github.com/atdasu/rojo/actions/workflows/ci.yml/badge.svg)](https://github.com/atdasu/rojo/actions/workflows/ci.yml)

A Roblox game template built with Luau, Rojo, Rokit, Wally and Lune. There is no
Node.js or compile step: the Luau in this repository is what runs in Roblox.

It ships with strict type-checking, linting, formatting, offline tests, a small
Vide UI kit, agent instructions and GitHub Actions. For the roblox-ts version see
[atdasu/rojo-typescript](https://github.com/atdasu/rojo-typescript).

## Use this template

1. Click **Use this template** on GitHub and create your repository.
2. Rename `StarterGame` in `default.project.json` and `src/shared/constants.luau`,
   and `starter/starter-game` in `wally.toml`. Update the title and badge above.
3. Follow [After creating a repository](docs/repository-setup.md) to turn on branch
   protection and the security features, which a template does not copy.

## Prerequisites

- [Rokit](https://github.com/rojo-rbx/rokit)
- Roblox Studio with the Rojo plugin installed

Everything else is pinned in `rokit.toml` and installed by Rokit.

## First-time setup

```powershell
rokit install
lune run install
```

`rokit install` installs the project-pinned tools: Rojo, Wally, Lune, StyLua, Selene,
luau-lsp and wally-package-types. Rokit asks you to trust each tool the first time.
`lune run install` materializes the dependencies in `wally.toml` into the ignored
`Packages` and `ServerPackages` directories.

## Development

```powershell
lune run dev
```

The command starts `rojo serve default.project.json` and keeps `sourcemap.json` up to
date for the Luau language server. In Roblox Studio, open the Rojo plugin, connect to
the running server, and changes sync as you save. Extra arguments are passed to
`rojo serve`, for example `lune run dev --port 34873`.

## Common commands

| Command            | Purpose                                                |
| ------------------ | ------------------------------------------------------ |
| `lune run dev`     | Serve the project to Studio and watch the sourcemap.   |
| `lune run check`   | Check formatting, lint, type-check, and run the tests. |
| `lune run test`    | Run the offline tests in `tests/`.                     |
| `lune run format`  | Format Luau source with StyLua.                        |
| `lune run install` | Install dependencies from `wally.toml`.                |
| `lune run build`   | Build `build/StarterGame.rbxl`.                        |

The commands are Lune scripts in `.lune/`. The first `lune run check` downloads the
Roblox type definitions for the pinned luau-lsp version into `globalTypes.d.luau`;
delete that file after changing the luau-lsp version.

## Project layout

| Path on disk     | Roblox location                             |
| ---------------- | ------------------------------------------- |
| `src/shared`     | `ReplicatedStorage.Shared`                  |
| `src/server`     | `ServerScriptService.Server`                |
| `src/client`     | `StarterPlayer.StarterPlayerScripts.Client` |
| `libraries/*`    | `ReplicatedStorage.InternalLibraries`       |
| `Packages`       | `ReplicatedStorage.Packages`                |
| `ServerPackages` | `ServerStorage.ServerPackages`              |

Rojo owns only those named folders. Every service in `default.project.json` sets
`$ignoreUnknownInstances`, so maps, lighting and anything else you build in Studio
next to the synced code is left alone. Inside a mapped folder Rojo removes whatever
is not on disk, so keep Studio-authored work out of them.

Because of that, a place built with `lune run build` contains code only. Do not
publish it over a place that holds Studio-authored content.

Source is type-checked in strict mode through the root `.luaurc`. See
[Dependency management](docs/dependency-management.md) for Wally packages and
internal libraries.

## Offline tests

`tests/*.luau` are Lune scripts. They require modules straight from `../src` and
run them with hand-made fakes, with no Studio needed:

```powershell
lune run test            # every test
lune run test lifetime   # tests/lifetime.luau only
```

This works because of two conventions:

- **Services take their dependencies as arguments**, for example
  `RoundService.new({ Players = Players, Workspace = workspace })`, instead of
  calling `game:GetService` themselves. A test passes plain tables in their place.
- **Pure logic lives in `src/shared`**, for example `src/shared/Math`, and never
  touches `game`, `script` or `workspace`.

Modules meant to be tested offline require each other with relative string paths
such as `require("./Curve")`, which resolve in both Roblox and Lune. Offline tests
prove logic only; rendering, input, replication and persistence still need a
playtest. More in [.ai/guides/testing.md](.ai/guides/testing.md).

## UI kit

UI is built with [Vide](https://centau.github.io/vide/) and previewed with
[UI Labs](https://ui-labs.luau.page/), both installed through Wally.

- Components live in `src/client/UI/<Name>/` and take all state through props.
- Each component has a sibling `<Name>.story.luau`. Install the UI Labs plugin in
  Studio and it lists every story in the place.
- `UI/ReactiveState.luau` is a per-field reactive store, `UI/Sfx.luau` decouples
  components from audio playback, and `Lifetime.luau` runs a cleanup exactly once
  when an instance goes away.

Not building UI with Vide? Delete `src/client/UI`, `src/client/Lifetime.luau`, their
two tests, the UI part of `src/client/main.client.luau` and the two packages in
`wally.toml`, then run `lune run install`.

## Working with coding agents

`AGENTS.md` is a short routing table that tells an agent which document to read for
which task; `CLAUDE.md` only imports it. `.claude/rules/` holds path-scoped
reminders, and `.ai/` holds the specs, guides, decisions and audits those routes
point to. Fill them in as the game takes shape and keep `AGENTS.md` short.

## Continuous integration

- **CI** (`.github/workflows/ci.yml`) runs `lune run check` and `lune run build` on
  every push to `main` and every pull request, and uploads the built place.
- **Release** (`.github/workflows/release.yml`) runs when you push a tag such as
  `v1.0.0`. It checks, builds, and attaches the place file to a GitHub release.
- **Dependabot** keeps the GitHub Actions up to date. It cannot read `rokit.toml` or
  `wally.toml`; update those by hand.
