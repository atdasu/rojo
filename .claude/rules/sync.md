---
paths:
  - "default.project.json"
---

Read .ai/guides/studio.md first. Keep `$ignoreUnknownInstances: true` on every
service and map code into named folders, never onto a service. Rojo deletes
unknown children inside a mapped folder, so inspect what a new mapping would
cover before adding it. Validate with `rojo sourcemap default.project.json`.
