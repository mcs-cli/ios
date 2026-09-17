## Swift LSP

The `LSP` tool is the only correct way to navigate this project's Swift symbols — it reads `sourcekit-lsp` + `xcode-build-server`, pinned to `.xcodebuildmcp/DerivedData/`.

### Rules

- **Never Grep, Glob, or file-read for Swift symbols** (types, functions, protocols, references, definitions). Use `hover`, `goToDefinition`, `workspaceSymbol`, `findReferences`, `documentSymbol`.
- **If `LSP` returns empty or `No such module 'X' (SourceKit)` for a symbol you expect to exist, stop.** Tell the user to run `/lsp-refresh`; do not fall back to Grep — the answer will be wrong.
- `workspaceSymbol` needs a specific `query`. An empty query is a bad query, not a no-result.
- iOS SDK types (`UIKit`, `SwiftUI`, `Foundation`, Objective-C interop) resolve with full type info — no need to web-search.
- Same-file edits are live. Cross-module changes need `/lsp-refresh` before other modules see them.
- Xcode.app builds do not warm this index; only XcodeBuildMCP builds populate `.xcodebuildmcp/DerivedData/`.
