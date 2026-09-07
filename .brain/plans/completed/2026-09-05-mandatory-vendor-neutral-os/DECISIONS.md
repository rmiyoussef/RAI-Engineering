# Decisions 2026-09-05-mandatory-vendor-neutral-os

- D1: plans/ over planning/ (spec convention). Completed history keeps old strings (append-only).
- D2: TEST-PLAN.md = plan-level test strategy; TC files remain source of truth for verdicts.
- D3: Manifest-based conflict policy (recorded-hash compare) over timestamp/prompt-only approaches.
- D4: update.sh owns .brain + .ai mirror + .gitignore; setup.sh delegates after fetching updater.
- D5: R9 model neutrality replaces model lock; registry identity check replaces model check.
- D6: .ai/ mirror under same safe policy (uniform install_file); adapters ensure-exist-only.
