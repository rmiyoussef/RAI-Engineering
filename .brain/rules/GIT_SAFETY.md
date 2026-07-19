# Git Safety Rules

> Rules for what must never be committed to Git, and how to protect sensitive information.

---

## R1 — Never Commit Secrets

The following must **never** appear in Git history:

- Database passwords, API keys, tokens
- `.env` files or environment files with real values
- Private SSH keys, certificates
- Service account credentials
- Connection strings with credentials
- Any file containing production secrets

**Always use environment variables.** `.env.example` with placeholder values is acceptable.

## R2 — `memory/connections/` Is Gitignored

The `memory/connections/` directory contains database schema info that the BRAIN reads. It may also contain or sit alongside sensitive information. **It must never be committed.**

Verify `.gitignore` contains:

```
# RAI-Engineering — Memory connections (may contain schema with sensitive paths)
memory/connections/
```

## R3 — Verify Before Commit

Before committing, check for:
- Debug mode enabled in config files
- Hardcoded `APP_KEY`, `DB_PASSWORD`, or similar
- `dd()`, `dump()`, `var_dump()`, `console.log()` debugging calls
- TODO comments with sensitive context
- Large binary files (uploads, databases, vendor/)

## R4 — No Production Data in Development

- Never commit production database dumps
- Never commit production log files
- Use factories/seeders for test data, not real data

## R5 — Commit Messages Never Contain Secrets

- No passwords, tokens, or keys in commit messages
- No server paths that reveal internal infrastructure
- No personal data in commit messages

## R6 — Sensitive Files Pattern

If you see any of these files being staged, flag it:

```
.env, .env.* (except .env.example)
*.key, *.pem, *.cert
storage/logs/*
*.sql (database dumps)
.DS_Store
Thumbs.db
node_modules/, vendor/ (already gitignored typically)
memory/connections/
```

## R7 — If Something Sensitive Was Committed

If sensitive data was already committed:

1. **Do NOT** just delete it — it's still in Git history
2. Rotate the exposed credentials immediately
3. Use `git filter-branch` or `bfg repo-cleaner` to remove from history
4. Force push to clean the remote

```bash
# Remove a file from all Git history
git filter-branch --force --index-filter \
  "git rm --cached --ignore-unmatch path/to/sensitive/file" \
  --prune-empty --tag-name-filter cat -- --all
```
