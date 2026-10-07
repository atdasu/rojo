---
paths:
  - "src/client/UI/**/*.luau"
---

Read .ai/specs/ui.md first. Components are Vide functions that take state and
callbacks through props; they never read game state, fire remotes or play audio
directly (use Sfx). Give every component a sibling `.story.luau` with fixture props.
