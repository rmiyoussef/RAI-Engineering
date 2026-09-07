# Decisions 2026-09-05-updater-self-refresh

- D1 Refresh running copy, not manifest-tracked. Updater excluded from SYSTEM_FILES by design (it is the runner). Dedicated refresh_self() instead.
- D2 Single .bak only. Repeat runs must not spam backups. Idempotency asserted.
- D3 Guard on parent dir .ai or --local. Protects curl-pipe cwd writes and remote clobber of dev workspaces.
