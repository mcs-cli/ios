## Swift LSP

The `LSP` tool reads `sourcekit-lsp` + `xcode-build-server`, pinned to `.xcodebuildmcp/DerivedData/`. Use it as the primary navigator, but understand what it does and does not see.

### Rules

- **First-use setup.** `LSP` is a deferred tool — its schema isn't loaded at session start. Run `ToolSearch(query="select:LSP", max_results=1)` once before your first `LSP` call, or the call errors with `InputValidationError`.
- **Navigation** (jump to a definition, follow one reference, look up a signature, list a file's symbols): use `hover`, `goToDefinition`, `workspaceSymbol`, `documentSymbol`. Do not Grep, Glob, or file-read for these — the LSP answer is correct and Grep is not.
- **Audit** (rename, signature change, deprecation, blast-radius sweep): treat `findReferences` as a **lower-bound estimate**. Sourcekit-lsp only indexes targets the last XcodeBuildMCP build compiled, so test targets, sibling framework targets, and stories outside the built scheme are silently omitted with no diagnostic. Always cross-check with the `Grep` tool on the symbol name and reconcile. Run `findReferences` on each overload separately — chained overloads (`init(any: String, …)` forwarding into `init(any: ColorModel, …)`) do not surface through a single call.
- **If `LSP` returns empty or `No such module 'X' (SourceKit)` for a symbol you expect to exist, stop.** Tell the user to run `/lsp-refresh` and wait — do not fall back to Grep for a navigation task, the answer will be wrong.
- `workspaceSymbol` needs a specific `query`. An empty query is a bad query, not a no-result.
- iOS SDK types (`UIKit`, `SwiftUI`, `Foundation`, Objective-C interop) resolve with full type info — no need to web-search.
- Same-file edits are live. Cross-module changes need `/lsp-refresh` before other modules see them.
- Sourcekit-lsp only indexes the **last built scheme's dependency graph**. `/lsp-refresh` builds with `buildForTesting: true` so test targets and their helpers are included, but stories and dev-tools outside every built scheme stay invisible — for those, the `Grep` tool is ground truth.
- Xcode.app builds do not warm this index; only XcodeBuildMCP builds populate `.xcodebuildmcp/DerivedData/`.
