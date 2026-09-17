## Build & Test (XcodeBuildMCP)

All build, test, and run operations go through **XcodeBuildMCP**. When a task requires building, testing, running, debugging, or interacting with simulators, **invoke the `xcodebuildmcp` skill first** to load the tool catalog and workflow guidance.

### Rules
- Call `session_show_defaults` before the first build/test to confirm the active project and simulator
- **Never** run `xcrun` or `xcodebuild` directly via Bash — always use XcodeBuildMCP tools
- **Never** build or test unless explicitly asked
- Always target project `__PROJECT__`; confirm the scheme with `xcodebuild -list -json` or ask when unclear
- **Never** suppress warnings — if any are related to the session, fix them
- Prefer `snapshot_ui` over `screenshot` (screenshot only as fallback)
- Bash `find` ignores `.gitignore` — prune `.xcodebuildmcp/` explicitly (`find . -path './.xcodebuildmcp' -prune -o …`) so it doesn't walk DerivedData. The `Grep` tool (ripgrep) honors gitignore and needs no guard.
