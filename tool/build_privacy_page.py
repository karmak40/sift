#!/usr/bin/env python3
"""Builds docs/index.html from PRIVACY.md for GitHub Pages hosting.

PRIVACY.md is the single source of truth (also rendered in-app by
lib/ui/settings/privacy_policy_screen.dart, via a small Dart parser
handling the same subset of markdown). This script mirrors that same
subset — '# '/'## ' headings, '- ' bullets, one leading '_italic_' line,
'**bold**' spans — for the public web copy, so there is exactly one place
the actual policy text is written.

Re-run this (`python3 tool/build_privacy_page.py`) whenever PRIVACY.md
changes, then commit the regenerated docs/index.html alongside it.
"""

import html
import re
from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parent.parent
SOURCE = REPO_ROOT / "PRIVACY.md"
OUTPUT = REPO_ROOT / "docs" / "index.html"

PAGE_TEMPLATE = """<!doctype html>
<html lang="en">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>Sift Privacy Policy</title>
<style>
  :root {{ color-scheme: light dark; }}
  body {{
    font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Helvetica, Arial, sans-serif;
    max-width: 680px;
    margin: 0 auto;
    padding: 48px 24px 80px;
    line-height: 1.6;
    color: #1b2432;
    background: #fbfcfd;
  }}
  @media (prefers-color-scheme: dark) {{
    body {{ color: #e6e9ee; background: #14181f; }}
    .muted {{ color: #9aa4b2 !important; }}
    .bullet::before {{ color: #9aa4b2; }}
  }}
  h1 {{ font-size: 1.7rem; font-weight: 700; margin: 0 0 4px; }}
  h2 {{ font-size: 1.2rem; font-weight: 600; margin: 28px 0 10px; }}
  p {{ margin: 0 0 14px; font-size: 0.98rem; }}
  .muted {{ color: #5b647a; font-size: 0.85rem; margin-bottom: 22px; }}
  ul {{ margin: 0 0 14px; padding: 0; list-style: none; }}
  li {{ margin: 0 0 8px; padding-left: 22px; position: relative; font-size: 0.98rem; }}
  li::before {{ content: "•"; position: absolute; left: 4px; color: #5841c8; }}
  a {{ color: #5841c8; }}
</style>
</head>
<body>
{body}
</body>
</html>
"""


def strip_bold(text: str) -> str:
    return text.replace("**", "")


def render_block(block_lines: list[str]) -> str:
    """Renders one blank-line-delimited block. A block is either a single
    heading/italic line, or a run of prose/list lines that need joining —
    PRIVACY.md hard-wraps at ~80 columns, so a paragraph or a list item's
    text is spread across multiple source lines that all belong together.
    """
    first = block_lines[0]
    if first.startswith("# "):
        return f"<h1>{html.escape(first[2:])}</h1>"
    if first.startswith("## "):
        return f"<h2>{html.escape(first[3:])}</h2>"
    if first.startswith("_") and first.endswith("_"):
        return f'<p class="muted">{html.escape(first[1:-1])}</p>'
    if first.startswith("- "):
        # A tight list: each line starting with '- ' begins a new item;
        # any other line in the block is a wrapped continuation of the
        # item immediately above it, joined with a space.
        items: list[str] = []
        for line in block_lines:
            stripped = line.strip()
            if stripped.startswith("- "):
                items.append(stripped[2:])
            else:
                items[-1] = f"{items[-1]} {stripped}"
        lis = "\n".join(f"<li>{html.escape(strip_bold(item))}</li>" for item in items)
        return f"<ul>\n{lis}\n</ul>"
    # Plain paragraph: every line in the block is a wrapped continuation of
    # the same sentence/paragraph — join with a space, not a line break.
    joined = " ".join(line.strip() for line in block_lines)
    return f"<p>{html.escape(strip_bold(joined))}</p>"


def render(markdown: str) -> str:
    blocks: list[list[str]] = []
    current: list[str] = []
    for raw_line in markdown.split("\n"):
        line = raw_line.rstrip()
        if not line:
            if current:
                blocks.append(current)
                current = []
            continue
        current.append(line)
    if current:
        blocks.append(current)
    return "\n".join(render_block(block) for block in blocks)


def main() -> None:
    markdown = SOURCE.read_text(encoding="utf-8")
    body = render(markdown)
    OUTPUT.parent.mkdir(parents=True, exist_ok=True)
    OUTPUT.write_text(PAGE_TEMPLATE.format(body=body), encoding="utf-8")
    print(f"Wrote {OUTPUT} ({OUTPUT.stat().st_size} bytes)")


if __name__ == "__main__":
    main()
