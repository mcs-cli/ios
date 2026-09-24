## Build & Test (MobileBuildMCP)

All build, test, run, debugging, and simulator operations go through **MobileBuildMCP** tools.

### Rules
- **Never** run `xcrun` or `xcodebuild` directly via Bash — always use MobileBuildMCP tools
- **Never** build or test unless explicitly asked
- Always use `__PROJECT__` with the appropriate scheme
- **Never** suppress warnings — if any are related to the session, fix them
- If an expected tool is missing, check `enabledWorkflows` in `.mobilebuildmcp/config.yaml` before assuming it doesn't exist
- Report the project, scheme, and simulator a build/test ran against; on failure, name the failing step and the next action
- Pass app runtime arguments in `launchArgs`; `extraArgs` is only for `xcodebuild` flags and build settings

### UI automation
- Prefer `snapshot_ui`; use `screenshot` only as a fallback
- Act on the element refs returned by the previous action or snapshot instead of guessing coordinates; pass `sinceScreenHash` to skip a full snapshot when the screen hasn't changed
- Use `wait_for_ui` instead of sleeping while the UI settles

### Housekeeping
- Bash `find` ignores `.gitignore` — prune `.mobilebuildmcp/` explicitly (`find . -path './.mobilebuildmcp' -prune -o …`) so it doesn't walk DerivedData. The `Grep` tool (ripgrep) honors gitignore and needs no guard.
- **Never** delete `.mobilebuildmcp/DerivedData` unless the user explicitly asks — it is the incremental build cache and rebuilding it is slow. If a build looks corrupted, report it instead of cleaning