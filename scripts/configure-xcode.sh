#!/bin/bash
# Configure Xcode project — creates .xcodebuildmcp/config.yaml and buildServer.json
# Environment variables provided by mcs:
#   MCS_PROJECT_PATH — absolute path to the project root
#   MCS_RESOLVED_PROJECT — resolved Xcode project/workspace file name
#   MCS_RESOLVED_SCHEME — main scheme (empty falls back to auto-detection)

set -euo pipefail

project_path="${MCS_PROJECT_PATH:?MCS_PROJECT_PATH not set}"
project_file="${MCS_RESOLVED_PROJECT:-}"

if [ -z "$project_file" ]; then
    echo "No Xcode project selected — skipping .xcodebuildmcp configuration"
    exit 0
fi

config_dir="$project_path/.xcodebuildmcp"
config_file="$config_dir/config.yaml"
derived_data_abs="$project_path/.xcodebuildmcp/DerivedData"

mkdir -p "$config_dir"
mkdir -p "$derived_data_abs"

cat > "$config_file" << EOF
schemaVersion: 1
enabledWorkflows:
  - simulator
  - ui-automation
  - project-discovery
  - utilities
  - session-management
  - debugging
  - logging
  - doctor
  - workflow-discovery
showTestTiming: true
sessionDefaults:
  projectPath: ./$project_file
  derivedDataPath: ./.xcodebuildmcp/DerivedData
  suppressWarnings: false
  platform: iOS
EOF

echo "Created $config_file for $project_file"

# Isolating DerivedData under the project keeps LSP indexing predictable, but
# xcode-build-server ties its buildServer.json to the same directory — pin it up
# front so sourcekit-lsp resolves symbols from XcodeBuildMCP-produced artifacts.
case "$project_file" in
    *.xcworkspace) xcbs_flag=(-workspace "$project_file") ;;
    *.xcodeproj)   xcbs_flag=(-project "$project_file") ;;
    *)
        echo "Unrecognized Xcode file '$project_file' — skipping buildServer.json"
        exit 0
        ;;
esac

if ! command -v xcode-build-server >/dev/null 2>&1; then
    echo "xcode-build-server not on PATH — skipping buildServer.json"
    exit 0
fi

scheme="${MCS_RESOLVED_SCHEME:-}"

if [ -z "$scheme" ]; then
    if ! command -v xcodebuild >/dev/null 2>&1 || ! command -v jq >/dev/null 2>&1; then
        echo "No scheme provided and xcodebuild or jq missing — skipping buildServer.json"
        exit 0
    fi
    # Prefer a scheme matching the workspace/project stem — Tuist emits
    # `Foo.generated.xcworkspace` for a scheme named `Foo`, so strip that too.
    stem="${project_file%.*}"
    stem="${stem%.generated}"
    scheme=$(cd "$project_path" && xcodebuild -list -json "${xcbs_flag[@]}" 2>/dev/null \
        | jq -r --arg stem "$stem" '
            (.workspace.schemes // .project.schemes // []) as $s
            | ($s | map(select(. == $stem)) | .[0]) // ($s | .[0]) // empty')
fi

if [ -z "$scheme" ]; then
    echo "Could not resolve a scheme for $project_file — skipping buildServer.json"
    echo "Re-run 'mcs sync' and answer the Main scheme prompt, or run:"
    echo "  xcode-build-server config ${xcbs_flag[*]} -scheme <name> --build_root $derived_data_abs"
    exit 0
fi

(cd "$project_path" && xcode-build-server config \
    "${xcbs_flag[@]}" \
    -scheme "$scheme" \
    --build_root "$derived_data_abs")

echo "Wrote $project_path/buildServer.json (scheme: $scheme, build_root: $derived_data_abs)"
