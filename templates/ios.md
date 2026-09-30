## iOS Simulator
- Always use the **booted simulator first**, referenced by **UUID** (not name)
- If no simulator is booted, **ask the user** which one to use

## Code Quality
- After modifying Swift files, run the project's formatter and linter before committing, **only on the files you edited in this task** (not everything in `git status`), passed as explicit paths
- Keep only the changes inside lines you edited; revert any hunks the tools produce elsewhere
