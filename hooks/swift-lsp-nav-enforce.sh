#!/bin/bash

set -euo pipefail
trap 'exit 0' ERR

command -v jq >/dev/null 2>&1 || exit 0

input=$(cat) || exit 0

# Unit Separator (0x1f) as IFS delimiter: non-whitespace so `read` does not
# collapse consecutive occurrences and empty middle fields survive.
IFS=$'\x1f' read -r tool file_path offset limit pattern glob grep_path < <(
    jq -r '[
        .tool_name // "",
        .tool_input.file_path // "",
        (.tool_input.offset // "" | tostring),
        (.tool_input.limit // "" | tostring),
        .tool_input.pattern // "",
        .tool_input.glob // "",
        .tool_input.path // ""
    ] | join("\u001f")' <<<"$input"
)

case "$tool" in
    Read)
        [[ "$file_path" == *.swift && -z "$offset" && -z "$limit" ]] || exit 0
        ;;
    Grep)
        # Any regex metachar in $pattern breaks the identifier regex, so
        # scoped/regex/multi-token queries pass through the case as audit shapes.
        [[ -z "$glob" && -z "$grep_path" && "$pattern" =~ ^[A-Za-z_][A-Za-z0-9_]+$ ]] || exit 0
        ;;
    *)
        exit 0
        ;;
esac

cat >&2 <<'EOF'
Swift navigation → use LSP, not Read/Grep.

LSP operations (call `ToolSearch(query="select:LSP")` first if not loaded):
  workspaceSymbol   — symbol lookup by name (needs a non-empty `query`)
  hover             — signature/doc at a position
  goToDefinition    — jump to definition at a position
  documentSymbol    — file outline
  findReferences    — reference list at a position

All ops require `filePath` (any real `.swift` file — the tool rejects `.` or a directory with `Path is not a file`), plus 1-based `line` and `character`.

For audit sweeps (rename, deprecation, Tests/) shape the call to pass:
  Grep — word-boundary regex (\bName\b) or a scope glob/path.
  Read — pass explicit offset/limit for a targeted slice.
EOF
exit 2
