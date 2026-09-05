---
name: caveman-ultra-install
description: Caveman token compressor installed at ULTRA level across all agents
metadata:
  type: project
---

# Caveman ULTRA — Token Compression Install

Installed [Caveman](https://github.com/juliusbrussee/caveman) at **ULTRA** level for max output token compression (~65% output reduction).

## Install Layers (all enforce ULTRA)

| Layer | Location | Value |
|---|---|---|
| Shell env var | `~/.zshrc` | `CAVEMAN_DEFAULT_MODE=ultra` |
| Claude Code env | `~/.claude/settings.json` env block | `CAVEMAN_DEFAULT_MODE=ultra` |
| Repo config | `.caveman.json` in project root | `{"defaultMode": "ultra"}` |
| User config | `~/.config/caveman/config.json` | `{"defaultMode": "ultra"}` |
| Flag file | `~/.claude/.caveman-active` | `ultra` |
| Per-repo rules | `AGENTS.md` in project root | ULTRA ruleset |
| Statusline badge | `~/.claude/settings.json` statusLine | Shows `[CAVEMAN]` |

## Agents Installed

- **Claude Code** — plugin manifest + SessionStart/UserPromptSubmit hooks (auto-activates)
- **Codex CLI** — all 7 skills installed
- **Cursor** — all 7 skills installed + per-repo rules
- **Hermes** — all 7 skills installed
- **ForgeCode** — all 7 skills installed

## Available Commands

- `/caveman [lite|full|ultra|wenyan]` — switch level on the fly
- `/caveman-stats` — show tokens saved
- `normal mode` — disable caveman

## What Compresses

Output tokens only (my responses). Code, commands, file paths, errors are never touched. Input tokens unaffected.

## Git Safety

`.caveman.json` is committed — it's a team-wide setting for ultra compression. No secrets in it.
