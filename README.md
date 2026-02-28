# iOS Development Pack

A [tech pack](https://github.com/bguidolim/mcs) that integrates Xcode build/test workflows, simulator management, and Apple documentation into Claude Code.

Built for the [`mcs`](https://github.com/bguidolim/mcs) configuration engine.

```
identifier: mcs-ios-pack
version:    1.0.0
requires:   mcs >= 2026.2.25
```

---

## What Is This?

This pack gives Claude Code full awareness of your iOS development environment — it can build, test, and run your app, manage simulators, and search Apple documentation, all without ever touching raw `xcodebuild` commands.

On session start, the pack detects your booted simulator and reports its UUID. During `mcs configure`, it auto-detects your `.xcodeproj` or `.xcworkspace` and generates the XcodeBuildMCP configuration.

---

## What's Included

### MCP Servers

| Server | Description |
|--------|-------------|
| **XcodeBuildMCP** | Build, test, run, and manage iOS simulators through Xcode |
| **Sosumi** | Apple developer documentation search |

### Skills

| Skill | Description |
|-------|-------------|
| **xcodebuildmcp** | Loads XcodeBuildMCP tool catalog and workflow guidance |

### Session Hooks

| Hook | Event | What It Does |
|------|-------|-------------|
| **ios-simulator-status.sh** | `SessionStart` | Detects booted iOS simulator and reports its name + UUID |

### Templates (CLAUDE.local.md)

| Section | Instructions |
|---------|-------------|
| **ios** | Use booted simulator by UUID, all builds via XcodeBuildMCP, never run `xcrun`/`xcodebuild` directly, prefer `snapshot_ui` over `screenshot` |

### Configuration Script

| Script | When | What It Does |
|--------|------|-------------|
| **configure-xcode.sh** | `mcs configure` | Creates `.xcodebuildmcp/config.yaml` with enabled workflows, project path, and platform settings |

---

## Installation

### Prerequisites

- macOS (Apple Silicon or Intel)
- [Claude Code](https://docs.anthropic.com/en/docs/claude-code) CLI
- Xcode Command Line Tools (`xcode-select --install`)

### Setup

```bash
# 1. Install mcs
brew install bguidolim/tap/my-claude-setup

# 2. Register this tech pack
mcs pack add bguidolim/mcs-ios-pack

# 3. Sync your project
cd ~/Developer/my-ios-project
mcs sync

# 4. Verify everything is healthy
mcs doctor
```

During `mcs sync`, you'll be prompted for:

| Prompt | What It Does | Default |
|--------|-------------|---------|
| **Xcode project** | Auto-detects `*.xcodeproj` / `*.xcworkspace` files for XcodeBuildMCP | *(detected)* |

---

## Directory Structure

```
mcs-ios-pack/
├── techpack.yaml                  # Manifest — defines all components
├── hooks/
│   └── ios-simulator-status.sh    # Booted simulator detection
├── templates/
│   └── ios.md                     # iOS rules for CLAUDE.local.md
└── scripts/
    └── configure-xcode.sh         # Creates .xcodebuildmcp/config.yaml
```

---

## You Might Also Be Interested In

| Pack | Description |
|------|-------------|
| [mcs-core-pack](https://github.com/bguidolim/mcs-core-pack) | Foundational settings, plugins, git workflows, and Serena code navigation |
| [mcs-continuous-learning](https://github.com/bguidolim/mcs-continuous-learning) | Persistent memory and knowledge management across sessions |

---

## Links

- [MCS (My Claude Setup)](https://github.com/bguidolim/mcs) — the configuration engine
- [Creating Tech Packs](https://github.com/bguidolim/mcs/blob/main/docs/creating-tech-packs.md) — guide for building your own
- [Tech Pack Schema](https://github.com/bguidolim/mcs/blob/main/docs/techpack-schema.md) — full YAML reference

---

## License

MIT
