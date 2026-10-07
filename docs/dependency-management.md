# Dependency management

This project has three dependency lanes. Keep a dependency in exactly one lane so
its installation, runtime location, and ownership are unambiguous.

| Lane               | Use it for                                  | Source of truth               | Roblox runtime location                                        |
| ------------------ | ------------------------------------------- | ----------------------------- | -------------------------------------------------------------- |
| Rokit              | Command-line tooling                        | `rokit.toml`                  | None; tools never ship with the game                           |
| Wally              | Luau/Roblox packages                        | `wally.toml` and `wally.lock` | `ReplicatedStorage.Packages` or `ServerStorage.ServerPackages` |
| Internal libraries | Reusable game Luau owned by this repository | `libraries/*`                 | `ReplicatedStorage.InternalLibraries`                          |

## Initial setup

Run this once after cloning and again after dependency-manifest changes:

```powershell
rokit install
lune run install
```

`lune run install` materializes Wally packages into the generated `Packages` and
`ServerPackages` directories. Do not edit either generated directory by hand.

## Tools

Add or update a tool with Rokit, then commit `rokit.toml`:

```powershell
rokit add <owner>/<repository>
rokit update <tool>
```

After changing the luau-lsp version, delete `globalTypes.d.luau` so the next
`lune run check` downloads the matching Roblox type definitions.

Dependabot cannot read `rokit.toml` or `wally.toml`, so tool and Wally updates are
manual. It does keep the GitHub Actions in `.github/workflows` current.

## Wally dependencies

Add shared packages under `[dependencies]` in `wally.toml`. Add packages that must
never replicate to clients under `[server-dependencies]`.

```toml
[dependencies]
# Example = "publisher/package@1.2.3"

[server-dependencies]
# ServerExample = "publisher/server-package@1.2.3"
```

Then install them:

```powershell
lune run install
```

The key on the left is the module name. Shared Wally dependencies are available at
`ReplicatedStorage.Packages` and may be required from shared, client, or server code:

```luau
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Example = require(ReplicatedStorage.Packages.Example)
```

Server Wally dependencies are placed in `ServerStorage.ServerPackages` and may only
be required by server code.

`lune run install` also runs wally-package-types, which rewrites Wally's generated
link modules so each package's exported types are visible to the language server.

Commit both `wally.toml` and `wally.lock`. Never commit generated package contents.

## Internal libraries

Internal libraries are folders in `libraries/*`. Rojo syncs each one as a
ModuleScript under `ReplicatedStorage.InternalLibraries`, so they are available to
shared, client, and server code. Require only a library's public root module.

The included `core` library is the reference implementation:

```luau
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local core = require(ReplicatedStorage.InternalLibraries.core)
```

### Add an internal library

For a new library named `inventory`, create this structure:

```text
libraries/inventory/
  init.luau
```

Return the supported API from `init.luau`. Keep private modules beside it and
require them as children:

```luau
local Slot = require(script.Slot)
```

Use it from game code with:

```luau
local inventory = require(ReplicatedStorage.InternalLibraries.inventory)
```

No registration step is needed; Rojo picks up the new folder. Run `lune run check`
afterward.

## Verification and routine commands

| Command            | What it checks or produces                                     |
| ------------------ | -------------------------------------------------------------- |
| `lune run check`   | Formatting, linting, strict type-checking, and offline tests   |
| `lune run install` | Installs Wally dependencies into generated package directories |
| `lune run build`   | Builds `build/StarterGame.rbxl` through Rojo                   |

Before opening a pull request, run `lune run check`, `lune run install` if the
Wally manifest changed, and `lune run build` for an end-to-end Rojo check.
