# Decisions 2026-09-07-readable-plan-naming

- D1 Scheme `<YYYY-MM-DD>-<slug>`, collision `-2`. Date = creation date. No PLAN- prefix, no counter file.
- D2 TC files `TC-NN.md` per plan. Full ref `<plan-id>/TC-NN`. tests.yaml qualified, TASKS.md bare within plan.
- D3 tests.yaml TC-0001..0008 attributed to 0007-slug (re-verified in 0007-era suite). TC-0009→0008, TC-0010→0009, TC-0011→0010.
- D4 Consumer migration slugifies heading + mtime. Only PLAN-XXXX-pattern dirs touched.
