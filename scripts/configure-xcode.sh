#!/bin/bash
# Configure Xcode project — creates .mobilebuildmcp/config.yaml
# Environment variables provided by mcs:
#   MCS_PROJECT_PATH — absolute path to the project root
#   MCS_RESOLVED_PROJECT — resolved Xcode project/workspace file name

set -euo pipefail

project_path="${MCS_PROJECT_PATH:?MCS_PROJECT_PATH not set}"
project_file="${MCS_RESOLVED_PROJECT:-}"

if [ -z "$project_file" ]; then
    echo "No Xcode project selected — skipping .mobilebuildmcp configuration"
    exit 0
fi

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
  projectPath: ./$project_file
  derivedDataPath: ./.mobilebuildmcp/DerivedData
  suppressWarnings: false
  platform: iOS
EOF

echo "Created $config_file for $project_file"
