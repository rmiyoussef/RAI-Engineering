# Environment

> Environments and configuration. Secrets never stored here.

- **Dev:** local checkout; run `python3 .ai/memory-timeline.py` to regenerate `TIMELINE.md`.
- **Install target:** any project dir via `./setup.sh`; updates via `./update.sh` (brain files only, never touches target `.brain/` memory).
- **Config:** optional `.brain/config.yaml` model tiers. Absent ⇒ host default for all agents.
- **Secrets:** DB connection details in `context/connections/` (gitignored). Never commit.
