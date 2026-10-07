# Decision register

Newest first. Record a decision when it constrains future work and its reason is
not obvious from the code. Do not erase an entry: mark it superseded and link the
entry that replaces it.

```markdown
## YYYY-MM-DD: short title

**Decision:** what was chosen.
**Why:** the constraint or evidence behind it.
**Consequences:** what this rules out or requires.
```

## Template: Rojo owns named folders only

**Decision:** Every service in `default.project.json` sets
`$ignoreUnknownInstances`, and code syncs into named folders (`Shared`, `Server`,
`Client`) rather than onto the services themselves.
**Why:** Maps, lighting and other Studio-authored content must survive a sync.
**Consequences:** A place built with `rojo build` contains code only. Do not
publish that file over a place that holds Studio-authored content.

## Template: tests run offline in Lune

**Decision:** Tests are Lune scripts that require source files directly.
**Why:** They run in seconds, in CI, without Studio.
**Consequences:** Services receive their dependencies as arguments and pure logic
stays free of `game` and `script`. Studio behavior still needs a playtest.
