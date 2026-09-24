## Build & Test (MobileBuildMCP)
- **Never** run `xcrun`, `xcodebuild`, or `simctl` via Bash — use MobileBuildMCP tools
- **Never** build or test unless explicitly asked
- **Never** suppress warnings — fix the ones related to the session
- Bash `find` ignores `.gitignore` — prune `.mobilebuildmcp/` explicitly (`find . -path './.mobilebuildmcp' -prune -o …`) so it doesn't walk DerivedData
- **Never** delete `.mobilebuildmcp/DerivedData` unless the user explicitly asks — it is the incremental build cache. If a build looks corrupted, report it instead of cleaning
