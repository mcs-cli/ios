## Swift LSP

The `LSP` tool reads `sourcekit-lsp` + `xcode-build-server`, pinned to `.xcodebuildmcp/DerivedData/`. Use it as the primary navigator, but understand what it does and does not see.

### Rules

- **First-use setup.** `LSP` is a deferred tool — its schema isn't loaded at session start. Run `ToolSearch(query="select:LSP", max_results=1)` once before your first `LSP` call, or the call errors with `InputValidationError`.
- **Navigation** (jump to a definition, follow one reference, look up a signature, list a file's symbols): use `hover`, `goToDefinition`, `workspaceSymbol`, `documentSymbol`. Enforced at tool-call time: whole-file or `limit`-only `Read` on `.swift` and bare-identifier `Grep` with no scope are blocked (exit 2). Targeted reads (with `offset`) and scoped Greps (glob, path, or word-boundary regex) pass through as audit shapes. The hook only sees the `Read` and `Grep` tools — substituting Bash `find`, `grep`, or `rg` on Swift files or bare symbols is the same rule violation, just uncaught.
- **Audit** (rename, signature change, deprecation, blast-radius sweep): treat `findReferences` as a **lower-bound estimate**. Sourcekit-lsp only indexes targets the last XcodeBuildMCP build compiled, so test targets, sibling framework targets, and stories outside the built scheme are silently omitted with no diagnostic. Always cross-check with the `Grep` tool on the symbol name and reconcile. Run `findReferences` on each overload separately — chained overloads (`init(any: String, …)` forwarding into `init(any: ColorModel, …)`) do not surface through a single call.
- **If `LSP` returns empty or `No such module 'X' (SourceKit)` for a symbol you expect to exist, stop.** Tell the user to run `/lsp-refresh` and wait — do not fall back to Grep for a navigation task, the answer will be wrong.
- `workspaceSymbol` needs a specific `query`. An empty query is a bad query, not a no-result.
- Every `LSP` operation — including workspace-scoped ones — needs `filePath` to point at a real file (any `.swift` in the workspace works). Passing `.` or a directory returns `Path is not a file`.
- iOS SDK types (`UIKit`, `SwiftUI`, `Foundation`, Objective-C interop) resolve with full type info — no need to web-search.
- Same-file edits are live. Cross-module changes need `/lsp-refresh` before other modules see them.
- Sourcekit-lsp only indexes the **last built scheme's dependency graph**. `/lsp-refresh` builds with `buildForTesting: true`, which only pulls in the test targets **declared in that scheme's test action** — modular workspaces where unit tests live on separate `<Module>Tests` schemes or under standalone test-plan schemes get partial or zero test coverage from a single app-scheme refresh. For any audit that could touch `Tests/`, treat the `Grep` tool as ground truth, not as a cross-check.
- Xcode.app builds do not warm this index; only XcodeBuildMCP builds populate `.xcodebuildmcp/DerivedData/`.
