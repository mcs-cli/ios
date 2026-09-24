<div align="center">

# iOS Development

### Build, test, and run your app without leaving the conversation.

[![MCS tech pack](https://img.shields.io/badge/MCS-tech%20pack-6f42c1)](https://github.com/mcs-cli/mcs)
[![Claude Code](https://img.shields.io/badge/Claude%20Code-compatible-d97757)](https://docs.anthropic.com/en/docs/claude-code)
![macOS](https://img.shields.io/badge/platform-macOS-111111)
![License](https://img.shields.io/badge/license-MIT-2ea44f)

</div>

Claude Code can already write Swift. What it cannot do out of the box is build that Swift, run it on a simulator, read the failure, and look up the API it got wrong. This pack closes the loop: every build, test, and simulator action routes through MobileBuildMCP, Apple's documentation is one search away, and the booted simulator is announced at session start so Claude targets a device by UUID instead of guessing at names.

```text
identifier: ios
requires:   mcs >= 2026.3.6
```

## Install

```bash
brew install mcs-cli/tap/mcs      # 1. install mcs
mcs pack add mcs-cli/ios          # 2. register this pack
cd ~/Developer/my-ios-project     # 3. sync from the project to configure
mcs sync
mcs doctor                        # 4. verify everything is healthy
```

**Prerequisites:** macOS, [Claude Code](https://docs.anthropic.com/en/docs/claude-code), and Xcode with its command line tools (`xcode-select --install`). `mcs` installs the remaining dependencies through Homebrew: the [MobileBuildMCP](https://github.com/getsentry/MobileBuildMCP) binary and `jq` for the simulator hook.

Install per project rather than globally. The pack asks which Xcode project or workspace to target and writes a `.mobilebuildmcp/config.yaml` beside it, so it needs to run from inside the repository.

## How it works

**There are no tool names to memorize.** Once installed, the rules and the tool catalog arrive on their own, and the pack keeps Claude pointed at the project and device you actually meant.

1. **Sync** — the pack detects your `.xcodeproj` or `.xcworkspace` and writes `.mobilebuildmcp/config.yaml` with the project path, `iOS` as the default platform, and the workflow set enabled. The file is gitignored for you.
2. **Session start** — a hook asks `simctl` for a booted simulator and reports its name and UUID as session context. Nothing is printed when no simulator is running.
3. **Before the first build** — the MobileBuildMCP server hands Claude its tool catalog and workflow guidance when the session connects, including the instruction to confirm the active project, scheme, and simulator with `session_show_defaults`.
4. **During work** — builds, tests, runs, simulator control, log capture, and UI automation all go through MobileBuildMCP. Raw `xcrun` and `xcodebuild` calls are off-limits, warnings get fixed rather than suppressed, and nothing is built or tested unless you ask for it.
5. **When an API is unfamiliar** — Sosumi searches Apple's developer documentation over MCP, with no local index to build and nothing extra to install.

## Configuration

Syncing asks one question: which Xcode project or workspace to use. `mcs` detects every `*.xcodeproj` and `*.xcworkspace` in the repository and offers them. The answer becomes `sessionDefaults.projectPath` in the generated config and fills the project placeholder in the build rules written to `CLAUDE.local.md`.

The generated `.mobilebuildmcp/config.yaml` pins the default platform to `iOS`, points DerivedData at `./.mobilebuildmcp/DerivedData/` so build artifacts stay in the repo (gitignored, survives worktree moves, kept as the incremental build cache), leaves `suppressWarnings` off, turns on test timing output, opts out of Sentry telemetry, and enables these workflows:

```text
simulator · simulator-management · ui-automation · project-discovery
utilities · session-management · debugging
```

To target a different project, or after renaming one, run `mcs sync` again. The config is regenerated at sync time rather than read from a runtime setting.

### Upgrading from XcodeBuildMCP

XcodeBuildMCP was renamed to MobileBuildMCP in v2.7.1. The next `mcs sync` swaps the MCP server, installs the `mobilebuildmcp` formula, and deletes the old `.xcodebuildmcp/` directory (DerivedData rebuilds once). Two leftovers are yours to remove:

```bash
brew uninstall xcodebuildmcp
rm -rf ~/.claude/skills/xcodebuildmcp   # the pack no longer installs a skill
```

Permission rules that allow `mcp__XcodeBuildMCP__*` need to be updated to `mcp__MobileBuildMCP__*`.

## What's included

| Component | What it does |
|---|---|
| **MobileBuildMCP** (MCP) | Builds, tests, runs, controls simulators, captures logs, and drives UI automation through the Homebrew `mobilebuildmcp` binary |
| **Sosumi** (MCP) | Searches Apple developer documentation over HTTP |
| **ios-simulator-status.sh** (hook) | Reports the booted simulator's name and UUID at session start |
| **configure-xcode.sh** (script) | Writes `.mobilebuildmcp/config.yaml` from the detected project at sync time |
| **ios.md** (template) | Simulator rules: booted device first and by UUID, ask when none is booted, run the formatter and linter after editing Swift |
| **mobilebuildmcp.md** (template) | Build rules: never call `xcrun` or `xcodebuild` directly, never suppress warnings, never delete DerivedData, prefer `snapshot_ui` and element refs over screenshots and coordinates |
| `.mobilebuildmcp` (gitignore) | Keeps the generated config out of version control |

`mcs doctor` additionally checks that the Xcode command line tools are installed, and offers `xcode-select --install` as the fix.

## Directory structure

```text
ios/
├── techpack.yaml                   # Manifest — defines all components
├── hooks/
│   └── ios-simulator-status.sh     # Booted simulator detection
├── templates/
│   ├── ios.md                      # Simulator and code quality rules
│   └── mobilebuildmcp.md           # Build/test rules for the detected project
└── scripts/
    └── configure-xcode.sh          # Writes .mobilebuildmcp/config.yaml
```

## You might also like

| Pack | Description |
|---|---|
| [dev](https://github.com/mcs-cli/dev) | Foundational settings, plugins, and Git workflows |
| [memory](https://github.com/mcs-cli/memory) | Persistent, project-specific memory across sessions |

## Links

- [MCS](https://github.com/mcs-cli/mcs) — the configuration engine
- [Creating Tech Packs](https://github.com/mcs-cli/mcs/blob/main/docs/creating-tech-packs.md)
- [Tech Pack Schema](https://github.com/mcs-cli/mcs/blob/main/docs/techpack-schema.md)

## License

MIT
