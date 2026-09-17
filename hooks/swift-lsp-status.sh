#!/bin/bash

set -euo pipefail
trap 'exit 0' ERR

command -v jq >/dev/null 2>&1 || exit 0

input_data=$(cat) || exit 0
echo "$input_data" | jq '.' >/dev/null 2>&1 || exit 0

project_dir="${CLAUDE_PROJECT_DIR:-}"
[ -n "$project_dir" ] || exit 0
[ -f "$project_dir/buildServer.json" ] || exit 0

build_root=$(jq -r '.build_root // empty' "$project_dir/buildServer.json" 2>/dev/null)
[ -n "$build_root" ] && [ -d "$build_root" ] || exit 0

# Cross-module symbols only resolve after xcodebuild has produced a SwiftFileList
# under build_root — surface the empty state so Claude offers /lsp-refresh
# instead of grepping around the error.
has_index=$(find "$build_root" -name '*.SwiftFileList' -print -quit 2>/dev/null)
[ -z "$has_index" ] || exit 0

jq -n '{
    hookSpecificOutput: {
        hookEventName: "SessionStart",
        additionalContext: "Swift LSP has no cached build. Tell the user to run `/lsp-refresh` and wait before using `LSP` for **navigation** queries — don'\''t fall back to Grep, the answer will be wrong. For **audit** tasks (rename, blast-radius) the `Grep` tool remains valid; treat any pre-refresh `LSP` result as a lower bound."
    }
}'
