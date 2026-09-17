---
description: Rebuild the workspace to refresh the Swift LSP index
---

# Refresh the Swift LSP index

Kick off a XcodeBuildMCP build so `sourcekit-lsp` sees new symbols. Use after adding an import, a new file, or a new module, or on `No such module 'X' (SourceKit)`.

## 1. Load the workflow

Invoke the `xcodebuildmcp` skill — its tool catalog and argument schemas prevent 3–5 rounds of guess-and-check. Do it even if you called it earlier in the session.

## 2. Read the scheme

```bash
jq -r '.scheme' buildServer.json
```

Returns the scheme `xcode-build-server config` was invoked with at sync time.

## 3. Pick any simulator — do not ask

Nothing is launched; the build just needs to succeed. In order of preference:

1. The booted simulator from the session-start context.
2. The default simulator recorded in `CLAUDE.md` or `CLAUDE.local.md`.
3. The first entry from `mcp__XcodeBuildMCP__list_sims`.

## 4. Prep the project

Some projects need to regenerate the Xcode workspace before `xcodebuild` will work — Tuist (`tuist generate`), xcodegen, Bazel, Makefile targets. Check the project's own documentation and any available memory/knowledge tools for a pre-build, regenerate, or bootstrap step, and run it. If nothing is documented, skip to the next step.

## 5. Build

Call `mcp__XcodeBuildMCP__build_sim` with that scheme, that simulator, and `buildForTesting: true`, and wait. The `buildForTesting` flag pulls test targets and testing-only helpers into the same DerivedData, so the LSP index covers them too — without it, `findReferences` silently misses call sites in tests and sibling test-helper frameworks. Do not run in parallel with other builds on the same worktree — they share `.xcodebuildmcp/DerivedData/`.

## 6. Verify

Run a `workspaceSymbol` query — the one that failed if you came from a `No such module` error, or a smoke test against a symbol you expect to exist. If it doesn't resolve, `pkill -TERM sourcekit-lsp xcode-build-server` and retry — respawn clears negatively-cached `No such module` responses.
