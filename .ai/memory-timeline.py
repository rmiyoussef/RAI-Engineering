#!/usr/bin/env python3
"""
RAI-Engineering — Memory Timeline Aggregator
Cross-references memory, summaries, and plans by date.
Produces a chronological timeline of project activity.

Usage:
    python3 .ai/memory-timeline.py              # Show last 30 days
    python3 .ai/memory-timeline.py --days 7     # Show last 7 days
    python3 .ai/memory-timeline.py --domain backend  # Filter by domains: metadata tag
    python3 .ai/memory-timeline.py --all        # Show everything

Output: Markdown timeline written to .brain/TIMELINE.md
"""

import os
import re
import sys
import json
from datetime import datetime, timedelta
from collections import defaultdict
from pathlib import Path

BRAIN_DIR = Path(os.path.dirname(os.path.abspath(__file__))) / ".." / ".brain"
DAYS_BACK = 30
DOMAIN_FILTER = None
SHOW_ALL = False

def parse_args():
    global DAYS_BACK, DOMAIN_FILTER, SHOW_ALL
    args = sys.argv[1:]
    i = 0
    while i < len(args):
        if args[i] == "--days" and i + 1 < len(args):
            DAYS_BACK = int(args[i + 1])
            i += 2
        elif args[i] == "--domain" and i + 1 < len(args):
            DOMAIN_FILTER = args[i + 1]
            i += 2
        elif args[i] == "--all":
            SHOW_ALL = True
            i += 1
        else:
            i += 1

def extract_date_from_filename(name: str):
    """Extract date from filenames like 2026-07-10-use-service-layer.md"""
    match = re.search(r'(\d{4}-\d{2}-\d{2})', name)
    if match:
        return match.group(1)
    return None

def extract_title_from_content(content: str):
    """Extract first heading from markdown content"""
    for line in content.split('\n'):
        line = line.strip()
        if line.startswith('# ') and len(line) > 2:
            return line[2:].strip()
    return None

def extract_date(content: str, file_path: Path):
    """Date from filename, else `Date:`/`Created:` field, else file mtime."""
    date = extract_date_from_filename(file_path.name)
    if date:
        return date
    m = re.search(r'(?:Date|Created):\s*(\d{4}-\d{2}-\d{2})', content)
    if m:
        return m.group(1)
    return datetime.fromtimestamp(file_path.stat().st_mtime).strftime('%Y-%m-%d')


def extract_domains(content: str):
    """Read `domains:` frontmatter metadata (new) or legacy path (old files)."""
    m = re.search(r'^domains:\s*\[(.*?)\]', content, re.MULTILINE)
    if m:
        return m.group(1).strip() or "all"
    return "all"


def collect_from_dir(dir_path: Path, category: str, entries: list, recursive_dirs=False):
    """Collect markdown files from a directory (optionally one level of subdirs, e.g. PLAN-XXXX/)."""
    if not dir_path.exists():
        return

    candidates = []
    for f in sorted(dir_path.iterdir()):
        if f.is_dir() and recursive_dirs and not f.name.startswith(('_', '.')):
            candidates += sorted([c for c in f.iterdir() if c.is_file() and c.suffix in ('.md', '.mdx')])
        elif f.is_file() and f.suffix in ('.md', '.mdx'):
            candidates.append(f)

    for f in candidates:
        # Plan scaffolding (STATUS/TASKS/CONTEXT/DECISIONS) is not timeline-worthy — only PLAN.md
        if f.name in ('STATUS.md', 'TASKS.md', 'CONTEXT.md', 'DECISIONS.md'):
            continue
        content = f.read_text(encoding='utf-8', errors='replace')
        date = extract_date(content, f)

        # Apply days filter
        if not SHOW_ALL:
            file_dt = datetime.strptime(date, '%Y-%m-%d')
            if file_dt < datetime.now() - timedelta(days=DAYS_BACK):
                continue

        title = extract_title_from_content(content[:800]) or f.stem

        entries.append({
            'date': date,
            'category': category,
            'title': title,
            'file': str(f.relative_to(BRAIN_DIR.parent)),
            'domain': extract_domains(content[:800]),
        })

def main():
    parse_args()
    
    entries = []

    # Purpose-organized sources: (path, category, recurse_into_subdirs?)
    sources = [
        ("memory/decisions", "📋 Decisions", False),
        ("memory/discoveries", "🔍 Discoveries", False),
        ("memory/lessons", "📝 Lessons", False),
        ("memory/incidents", "🚨 Incidents", False),
        ("memory/sessions", "💬 Sessions", False),
        ("summaries/active", "📦 Summaries", False),
        ("summaries/completed", "📦 Summaries", False),
        ("summaries/archived", "📦 Summaries", False),
        ("plans/active", "🗺️ Plans", True),
        ("plans/completed", "🗺️ Plans", True),
        ("plans/blocked", "🗺️ Plans", True),
        ("plans/archived", "🗺️ Plans", True),
        ("test-cases/completed", "🧪 Test Cases", True),
    ]
    for rel, category, recursive in sources:
        collect_from_dir(BRAIN_DIR / rel, category, entries, recursive_dirs=recursive)
    
    # Sort by date (newest first)
    entries.sort(key=lambda e: e['date'], reverse=True)
    
    # Apply domain filter
    if DOMAIN_FILTER:
        entries = [e for e in entries if DOMAIN_FILTER.lower() in e['domain'].lower()]
    
    if not entries:
        print(f"No memory entries found{' for domain: ' + DOMAIN_FILTER if DOMAIN_FILTER else ''}.")
        print(f"Searched {DAYS_BACK} days in .brain/memory/, .brain/summaries/, .brain/plans/")
        return
    
    # Group by date
    by_date = defaultdict(list)
    for e in entries:
        by_date[e['date']].append(e)
    
    # Build timeline markdown
    lines = []
    lines.append("# 🧠 Project Memory Timeline")
    lines.append(f"\n> **Generated:** {datetime.now().strftime('%Y-%m-%d %H:%M')}")
    lines.append(f"> **Window:** Last {'all time' if SHOW_ALL else f'{DAYS_BACK} days'}")
    if DOMAIN_FILTER:
        lines.append(f"> **Filter:** `{DOMAIN_FILTER}`")
    lines.append(f"> **Total entries:** {len(entries)}")
    lines.append("")
    lines.append("---")
    lines.append("")
    
    for date_str in sorted(by_date.keys(), reverse=True):
        day_entries = by_date[date_str]
        dt = datetime.strptime(date_str, '%Y-%m-%d')
        day_label = dt.strftime('%A, %B %d, %Y')
        lines.append(f"## 📅 {day_label}")
        lines.append("")
        
        for e in day_entries:
            domain_tag = f"`{e['domain']}`" if e['domain'] not in ('all', '') else ""
            lines.append(f"- **{e['category']}** — [{e['title']}]({e['file']}) {domain_tag}")
        
        lines.append("")
    
    # Summary stats
    lines.append("---")
    lines.append("## 📊 Summary")
    lines.append("")
    lines.append("| Category | Count |")
    lines.append("|----------|-------|")
    
    cat_counts = defaultdict(int)
    for e in entries:
        cat_counts[e['category']] += 1
    
    for cat in sorted(cat_counts.keys()):
        lines.append(f"| {cat} | {cat_counts[cat]} |")
    
    # Write output
    output_path = BRAIN_DIR / "TIMELINE.md"
    output_path.write_text('\n'.join(lines), encoding='utf-8')
    
    print(f"✅ Timeline written to {output_path}")
    print(f"   {len(entries)} entries across {len(by_date)} days")

if __name__ == '__main__':
    main()
