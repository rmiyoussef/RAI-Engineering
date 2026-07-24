#!/usr/bin/env python3
"""
RAI-Engineering — Memory Timeline Aggregator
Cross-references decisions, lessons, sessions, tests, and tasks by date.
Produces a chronological timeline of project activity.

Usage:
    python3 .ai/memory-timeline.py              # Show last 30 days
    python3 .ai/memory-timeline.py --days 7     # Show last 7 days
    python3 .ai/memory-timeline.py --domain backend  # Filter by domain
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

def collect_from_dir(dir_path: Path, category: str, entries: list):
    """Recursively collect markdown files from a directory"""
    if not dir_path.exists():
        return
    
    for f in sorted(dir_path.iterdir()):
        if not f.is_file() or f.suffix not in ('.md', '.mdx'):
            continue
        
        date = extract_date_from_filename(f.name)
        if not date:
            continue
        
        # Apply days filter
        if not SHOW_ALL:
            file_dt = datetime.strptime(date, '%Y-%m-%d')
            if file_dt < datetime.now() - timedelta(days=DAYS_BACK):
                continue
        
        content = f.read_text(encoding='utf-8', errors='replace')[:500]
        title = extract_title_from_content(content) or f.stem
        
        entries.append({
            'date': date,
            'category': category,
            'title': title,
            'file': str(f.relative_to(BRAIN_DIR.parent)),
            'domain': extract_domain(f, dir_path),
        })

def extract_domain(file_path: Path, base_dir: Path):
    """Extract domain from path like .brain/backend/memory/..."""
    parts = file_path.relative_to(BRAIN_DIR).parts
    if len(parts) > 0:
        domain = parts[0]
        if domain in ('backend', 'frontend', 'mobile-ios', 'mobile-android', 'devops'):
            # Check if it's inside memory/
            if 'memory' in parts:
                idx = parts.index('memory')
                if idx + 1 < len(parts):
                    return f"{domain}/{parts[idx + 1]}"
            return domain
    return "shared"

def main():
    parse_args()
    
    entries = []
    
    # Find all domain directories
    domains = ['backend', 'frontend', 'mobile-ios', 'mobile-android', 'devops']
    
    for domain in domains:
        domain_base = BRAIN_DIR / domain
        if not domain_base.exists():
            continue
        
        memory_dir = domain_base / "memory"
        if not memory_dir.exists():
            continue
        
        # Collect from each memory subdirectory
        for sub in ['decisions', 'lessons', 'sessions', 'tests', 'tasks', 'architecture', 'business']:
            sub_dir = memory_dir / sub
            if sub_dir.exists():
                collect_from_dir(sub_dir, f"📋 {sub.capitalize()}", entries)
    
    # Sort by date (newest first)
    entries.sort(key=lambda e: e['date'], reverse=True)
    
    # Apply domain filter
    if DOMAIN_FILTER:
        entries = [e for e in entries if DOMAIN_FILTER.lower() in e['domain'].lower()]
    
    if not entries:
        print(f"No memory entries found{' for domain: ' + DOMAIN_FILTER if DOMAIN_FILTER else ''}.")
        print(f"Searched {DAYS_BACK} days in .brain/*/memory/*/")
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
            domain_tag = f"`{e['domain']}`" if e['domain'] != 'shared' else ""
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
