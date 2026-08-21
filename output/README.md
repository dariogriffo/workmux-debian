<div align="center">

# workmux

**Parallel development in tmux with git worktrees.**

![GitHub Release](https://img.shields.io/github/v/release/raine/workmux?display_name=tag&color=%23a6a)
![GitHub License](https://img.shields.io/github/license/raine/workmux)

</div>

## About

workmux is a giga opinionated, zero-friction workflow tool for managing
[git worktrees](https://git-scm.com/docs/git-worktree) and tmux windows as
isolated development environments. It is built for running several features —
or several AI coding agents — in parallel without stashing, branch switching or
conflicts.

**Philosophy**: build on tools you already use. tmux/zellij/kitty/WezTerm for
windowing, git for worktrees, your agent for coding — workmux ties them
together.

**[Read the documentation](https://workmux.raine.dev/)**

## Requirements

- `git`
- A terminal multiplexer: [tmux](https://github.com/tmux/tmux) by default, or
  [WezTerm](https://workmux.raine.dev/guide/wezterm),
  [kitty](https://workmux.raine.dev/guide/kitty) or
  [Zellij](https://workmux.raine.dev/guide/zellij).

## Quick start

1. **Initialize configuration (optional)**

   ```sh
   workmux init
   ```

   This creates a `.workmux.yaml` file to customize your workflow (pane
   layouts, setup commands, file operations, and so on). workmux works out of
   the box with sensible defaults, so this step is optional.

2. **Create a new worktree and tmux window**

   ```sh
   workmux add new-feature
   ```

   This creates a git worktree at
   `<project_root>/../<project_name>__worktrees/new-feature`, copies config
   files and symlinks dependencies (if configured), runs any `post_create`
   setup commands, creates a tmux window named `wm-new-feature`, sets up your
   pane layout and switches to it.

3. **Do your thing**

4. **Finish and clean up**

   **Local merge:** run `workmux merge` to merge into the base branch and clean
   up in one step.

   **PR workflow:** push and open a PR. After it is merged, run
   `workmux remove` to clean up.

## Commands

```
Worktree lifecycle:
  add          Create a new worktree and tmux window
  remove       Remove a worktree, tmux window, and branch without merging [rm]
  rename       Rename a worktree, tmux window/session, and optionally branch
  merge        Merge a branch, then clean up the worktree and tmux window
  rebase       Rebase a worktree branch onto its base branch
  open         Open a tmux window for an existing worktree
  close        Close a worktree's tmux window (keeps the worktree and branch)
  resurrect    Restore worktree windows after a tmux or computer crash

Monitoring:
  dashboard    Show a TUI dashboard of all active workmux agents
  sidebar      Toggle a live agent status sidebar in tmux
  list         List all worktrees [ls]
  path         Get the filesystem path of a worktree
  status       Query agent status for worktrees

Setup and configuration:
  init         Generate example .workmux.yaml configuration file
  setup        Set up agent status tracking hooks and install skills
  config       Manage global configuration
  sandbox      Manage sandbox settings
  sync-files   Re-apply file operations (copy/symlink) to worktrees
  claude       Claude Code integration commands

Agent interaction:
  send         Send a prompt or instruction to a running agent
  capture      Capture terminal output from a running agent
  wait         Wait for agents to reach a target status
  run          Run a command in a worktree's window
  reap-agents  Exit tracked agent processes older than a configured age
```

Run `workmux docs` for the full documentation, or `workmux changelog` to see
what is new in each version.

## Configuration

workmux uses a two-level configuration system:

- **Global** (`~/.config/workmux/config.yaml`): personal defaults for all
  projects.
- **Project** (`.workmux.yaml`): project-specific overrides.

Project settings override global settings. When you run workmux from a
subdirectory it walks upward to find the nearest `.workmux.yaml`, which allows
nested configs for monorepos.

```yaml
# ~/.config/workmux/config.yaml
nerdfont: true          # Enable nerdfont icons (prompted on first run)
merge_strategy: rebase  # Make workmux merge do a rebase by default
agent: claude

panes:
  - command: <agent>    # Start the configured agent (e.g. claude)
    focus: true
  - split: horizontal   # Second pane with the default shell
```

See [Configuration](https://workmux.raine.dev/) for the full list of options.

## Shell completions

This package installs bash, fish and zsh completions automatically. They are
generated with `workmux completions <shell>`, which also supports elvish and
PowerShell if you need them.

## Documentation

- [Documentation site](https://workmux.raine.dev/)
- [Introduction blog post](https://raine.dev/blog/introduction-to-workmux/)
- [Changelog](https://github.com/raine/workmux/blob/main/CHANGELOG.md)
- [Upstream repository](https://github.com/raine/workmux)
