#!/usr/bin/env python3
"""Recursively inline local Structurizr DSL !include directives."""
from __future__ import annotations

import argparse
from pathlib import Path
import re

INCLUDE_RE = re.compile(r'^(?P<indent>\s*)!include\s+(?P<path>\S+)\s*$')


def inline_file(path: Path, stack: tuple[Path, ...] = ()) -> str:
    path = path.resolve()
    if path in stack:
        chain = " -> ".join(str(p) for p in (*stack, path))
        raise RuntimeError(f"Cyclic include detected: {chain}")
    lines: list[str] = []
    for raw in path.read_text(encoding="utf-8").splitlines():
        match = INCLUDE_RE.match(raw)
        if not match:
            lines.append(raw)
            continue
        target = (path.parent / match.group("path")).resolve()
        if not target.is_file():
            raise FileNotFoundError(f"Include not found: {target}")
        indent = match.group("indent")
        included = inline_file(target, (*stack, path)).splitlines()
        lines.append(f"{indent}# BEGIN INCLUDE: {target.name}")
        for line in included:
            lines.append(indent + line if line else "")
        lines.append(f"{indent}# END INCLUDE: {target.name}")
    return "\n".join(lines) + "\n"


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("source", type=Path)
    parser.add_argument("destination", type=Path)
    parser.add_argument(
        "--portable",
        action="store_true",
        help="Remove local !docs and !adrs directives from the inlined workspace.",
    )
    args = parser.parse_args()
    text = inline_file(args.source)
    if args.portable:
        text = re.sub(r'^\s*!docs\s+\S+\s*$', '', text, flags=re.MULTILINE)
        text = re.sub(r'^\s*!adrs\s+\S+(?:\s+\S+)?\s*$', '', text, flags=re.MULTILINE)
    args.destination.write_text(text, encoding="utf-8")


if __name__ == "__main__":
    main()
