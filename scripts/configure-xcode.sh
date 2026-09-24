#!/bin/bash
# Configure Xcode project — creates .mobilebuildmcp/config.yaml
# Environment variables provided by mcs:
#   MCS_PROJECT_PATH — absolute path to the project root
#   MCS_RESOLVED_PROJECT — resolved Xcode project/workspace file name

set -euo pipefail

project_path="${MCS_PROJECT_PATH:?MCS_PROJECT_PATH not set}"
project_file="${MCS_RESOLVED_PROJECT:-}"
project_file="${project_file#./}"

if [ -z "$project_file" ]; then
    echo "No Xcode project selected — skipping .mobilebuildmcp configuration"
    exit 0
fi

# MobileBuildMCP maps these to xcodebuild -workspace / -project and rejects both at once.
# The file isn't required to exist yet, so generated projects can be configured before generation.
case "$project_file" in
    *.xcworkspace) path_key="workspacePath" ;;
    *.xcodeproj)   path_key="projectPath" ;;
    *)
        echo "Unsupported project '$project_file' — expected .xcworkspace or .xcodeproj; skipping .mobilebuildmcp configuration" >&2
        exit 0
        ;;
esac

# MobileBuildMCP (formerly XcodeBuildMCP) no longer reads the old directory
legacy_dir="$project_path/.xcodebuildmcp"
if [ -d "$legacy_dir" ]; then
    rm -rf "$legacy_dir"
    echo "Removed legacy $legacy_dir"
fi

config_dir="$project_path/.mobilebuildmcp"
config_file="$config_dir/config.yaml"

mkdir -p "$config_dir"

cat > "$config_file" << EOF
schemaVersion: 1
enabledWorkflows:
  - simulator
  - simulator-management
  - ui-automation
  - project-discovery
  - utilities
  - session-management
  - debugging
showTestTiming: true
sentryDisabled: true
sessionDefaults:
  $path_key: ./$project_file
  derivedDataPath: ./.mobilebuildmcp/DerivedData
  suppressWarnings: false
  platform: iOS
EOF

echo "Created $config_file for $project_file"
