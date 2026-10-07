# Architecture

## Where code lives

| Path on disk     | Roblox location                                   | Runs on           |
| ---------------- | ------------------------------------------------- | ----------------- |
| `src/shared`     | `ReplicatedStorage.Shared`                        | Server and client |
| `src/server`     | `ServerScriptService.Server`                      | Server            |
| `src/client`     | `StarterPlayer.StarterPlayerScripts.Client`       | Client            |
| `libraries/*`    | `ReplicatedStorage.InternalLibraries`             | Server and client |
| `Packages`       | `ReplicatedStorage.Packages` (Wally, generated)   | Server and client |
| `ServerPackages` | `ServerStorage.ServerPackages` (Wally, generated) | Server            |

Each mapping is a named folder inside its service, and every service sets
`$ignoreUnknownInstances`. Rojo therefore owns only those folders: anything a
person builds in Studio beside them is preserved. Inside a mapped folder Rojo
removes whatever is not on disk, so never put Studio-authored work there.

## Module conventions

- **Entry scripts are thin.** `main.server.luau` and `main.client.luau` fetch
  Roblox services, construct modules and connect them. They hold no logic.
- **Services take their dependencies as arguments.** A service is a module with
  a constructor that receives everything it touches:

  ```luau
  local service = RoundService.new({ Players = Players, Workspace = workspace })
  ```

  It never calls `game:GetService` itself, so a test can pass hand-made fakes.

- **Pure logic lives in `src/shared`**, for example `src/shared/Math`. Pure modules
  take values and return values. They do not touch `game`, `script` or `workspace`.
- **Offline-testable modules use relative string requires** such as
  `require("./Curve")`. These resolve in Roblox and in Lune. A module that requires
  through `game` or `script` can only run inside Roblox.
- Require only the public root of an internal library or package.

## Authority

The server owns simulation results, inventory, currency, purchases and saved data,
and validates every request a client sends. Clients own input and presentation.
Nothing secret or server-only is placed under `ReplicatedStorage`.
