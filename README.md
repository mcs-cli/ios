<div align="center">

# iOS Development

### Build, test, and run your app without leaving the conversation.

[![MCS tech pack](https://img.shields.io/badge/MCS-tech%20pack-6f42c1)](https://github.com/mcs-cli/mcs)
[![Claude Code](https://img.shields.io/badge/Claude%20Code-compatible-d97757)](https://docs.anthropic.com/en/docs/claude-code)
![macOS](https://img.shields.io/badge/platform-macOS-111111)
![License](https://img.shields.io/badge/license-MIT-2ea44f)

</div>

Claude Code can already write Swift. What it cannot do out of the box is build that Swift, run it on a simulator, read the failure, look up the API it got wrong, and navigate the workspace by symbol instead of by text. This pack closes the loop: every build, test, and simulator action routes through XcodeBuildMCP, `sourcekit-lsp` resolves symbols across the workspace via `xcode-build-server`, Apple's documentation is one search away, and the booted simulator is announced at session start so Claude targets a device by UUID instead of guessing at names.

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

After the first `mcs sync`, run `/lsp-refresh` once from Claude to hydrate the LSP index — until a build populates `.xcodebuildmcp/DerivedData/`, cross-module symbols return `No such module`.

**Prerequisites:** macOS, [Claude Code](https://docs.anthropic.com/en/docs/claude-code), and Xcode with its command line tools (`xcode-select --install`). `mcs` installs the remaining dependencies through Homebrew: the [XcodeBuildMCP](https://github.com/getsentry/xcodebuildmcp) binary, [xcode-build-server](https://github.com/SolaWing/xcode-build-server) for the Swift LSP bridge, `jq` for the simulator hook, and Node.js for the skill installer.

Install per project rather than globally. The pack asks which Xcode project or workspace to target and writes a `.xcodebuildmcp/config.yaml` beside it, so it needs to run from inside the repository.

## How it works

**There are no tool names to memorize.** Once installed, the rules and the tool catalog arrive on their own, and the pack keeps Claude pointed at the project and device you actually meant.

1. **Sync** — the pack detects your `.xcodeproj` or `.xcworkspace`, writes `.xcodebuildmcp/config.yaml` pinning DerivedData to `.xcodebuildmcp/DerivedData/`, then auto-detects the primary scheme and runs `xcode-build-server config` to generate `buildServer.json` at the project root. Both are gitignored for you.
2. **Session start** — one hook asks `simctl` for a booted simulator and reports its UUID; a second hook warns when the Swift LSP has no cached build yet. Either can be uninstalled independently.
3. **Before the first build** — `CLAUDE.local.md` tells Claude to invoke the `xcodebuildmcp` skill for the tool catalog and workflow guidance, then to confirm the active project and simulator with `session_show_defaults`.
4. **During work** — builds, tests, runs, simulator control, log capture, and UI automation all go through XcodeBuildMCP. `sourcekit-lsp` resolves symbols, definitions, and workspace-wide references from the shared `.xcodebuildmcp/DerivedData/` index. Raw `xcrun` and `xcodebuild` calls are off-limits, warnings get fixed rather than suppressed, and nothing is built or tested unless you ask for it.
5. **When symbols drift** — `/lsp-refresh` rebuilds through XcodeBuildMCP so the LSP index picks up new imports, files, and cross-module changes.
6. **When an API is unfamiliar** — Sosumi searches Apple's developer documentation over MCP, with no local index to build and nothing extra to install.

## Configuration

Syncing asks two questions: the Xcode project or workspace, and the main scheme. The project answer becomes `sessionDefaults.projectPath`, fills the project placeholder in `CLAUDE.local.md`, and is fed to `xcode-build-server config` to generate `buildServer.json`. The scheme answer is passed to the same command; leave it blank and `configure-xcode.sh` runs `xcodebuild -list -json` and prefers a scheme whose name matches the workspace stem (Tuist's `Foo.generated.xcworkspace` maps to a `Foo` scheme).

The generated `.xcodebuildmcp/config.yaml` pins the default platform to `iOS`, points DerivedData at `./.xcodebuildmcp/DerivedData/` so build artifacts stay in the repo (gitignored, easy to prune, survives worktree moves) and the LSP always reads from a stable path, leaves `suppressWarnings` off, turns on test timing output, and enables these workflows:

```text
simulator · ui-automation · project-discovery · utilities
session-management · debugging · logging · doctor · workflow-discovery
```

To target a different project, or after renaming one, run `mcs sync` again. The config is regenerated at sync time rather than read from a runtime setting.

## What's included

| Component | What it does |
|---|---|
| **XcodeBuildMCP** (MCP) | Builds, tests, runs, controls simulators, captures logs, and drives UI automation through the Homebrew `xcodebuildmcp` binary |
| **xcode-build-server** (brew) | Build Server Protocol adapter that feeds `xcodebuild`'s output to `sourcekit-lsp` |
| **swift-lsp** (plugin) | Surfaces the `LSP` tool backed by `sourcekit-lsp` for hover, goto-definition, workspace symbols, and references |
| **Sosumi** (MCP) | Searches Apple developer documentation over HTTP |
| **xcodebuildmcp** (skill) | Loads the XcodeBuildMCP tool catalog and workflow guidance before the first build |
| **ios-simulator-status.sh** (hook) | Reports the booted simulator at session start |
| **swift-lsp-status.sh** (hook) | Warns at session start when the Swift LSP has no cached build |
| **configure-xcode.sh** (script) | Writes `.xcodebuildmcp/config.yaml` and `buildServer.json` from the detected project and scheme at sync time |
| **/lsp-refresh** (command) | Rebuilds through XcodeBuildMCP so the Swift LSP index picks up new imports and cross-module changes |
| **ios.md** (template) | Simulator rules: booted device first and by UUID, ask when none is booted, run the formatter and linter after editing Swift |
| **xcodebuildmcp.md** (template) | Build rules: skill first, verify session defaults, never call `xcrun` or `xcodebuild` directly, never suppress warnings, prefer `snapshot_ui` over `screenshot` |
| **swift-lsp.md** (template) | LSP rules: prefer `LSP` over Grep, `workspaceSymbol` needs a specific query, `/lsp-refresh` on `No such module`, Xcode.app builds don't warm the index |
| `.xcodebuildmcp` / `buildServer.json` (gitignore) | Keeps the generated config, DerivedData, and BSP manifest out of version control |

`mcs doctor` additionally checks that the Xcode command line tools are installed, and offers `xcode-select --install` as the fix.

## Directory structure

```text
ios/
├── techpack.yaml                   # Manifest — defines all components
├── hooks/
│   ├── ios-simulator-status.sh     # Booted simulator detection
│   └── swift-lsp-status.sh         # LSP freshness check
├── commands/
│   └── lsp-refresh.md              # /lsp-refresh — rebuilds to hydrate the LSP index
├── templates/
│   ├── ios.md                      # Simulator and code quality rules
│   ├── xcodebuildmcp.md            # Build/test rules for the detected project
│   └── swift-lsp.md                # Swift LSP navigation rules
└── scripts/
    └── configure-xcode.sh          # Writes .xcodebuildmcp/config.yaml and buildServer.json
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
