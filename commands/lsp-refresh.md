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

## 4. Build

Call `mcp__XcodeBuildMCP__build_sim` with that scheme and simulator, and wait. Do not run in parallel with other builds on the same worktree — they share `.xcodebuildmcp/DerivedData/`.

## 5. Verify

Retry the `workspaceSymbol` query that failed. If it still doesn't resolve, `pkill -TERM sourcekit-lsp xcode-build-server` and retry — respawn clears negatively-cached `No such module` responses.
