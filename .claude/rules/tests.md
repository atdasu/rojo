---
paths:
  - "tests/**/*.luau"
---

Read .ai/guides/testing.md first. Tests run offline in Lune: require modules by
relative path, pass hand-made fakes, assert, and print one PASS line. If a module
cannot be required offline, move its logic out of the Roblox calls rather than
faking `game`. Run with `lune run test <name>`.
