#!/usr/bin/env python3
"""Static consistency checks for the generated Structurizr DSL workspace.

This does not replace the official Structurizr parser. It catches unresolved identifiers,
duplicate aliases/view keys, brace/quote errors, and dynamic relationships that have no
corresponding static model relationship.
"""
from __future__ import annotations

import argparse
from collections import Counter, defaultdict
from dataclasses import dataclass
from pathlib import Path
import re
import sys

ALIAS_RE = re.compile(
    r'^\s*([A-Za-z_][A-Za-z0-9_]*)\s*=\s*'
    r'(person|softwareSystem|container|component|element|deploymentEnvironment|deploymentGroup|deploymentNode|infrastructureNode|softwareSystemInstance|containerInstance)\b'
)
REL_RE = re.compile(r'^\s*(?:[0-9A-Za-z_.-]+:\s*)?([A-Za-z_][A-Za-z0-9_.]*)\s*->\s*([A-Za-z_][A-Za-z0-9_.]*)\b')
VIEW_RE = re.compile(
    r'^\s*(systemLandscape|systemContext|container|component|custom|dynamic|deployment)\s+'
    r'(?:(?:[^"{]+)\s+)?"([A-Za-z0-9_.-]+)"(?:\s|\{)'
)
INCLUDE_RE = re.compile(r'^\s*include\s+(.+)$')
TOKEN_RE = re.compile(r'^[A-Za-z_][A-Za-z0-9_.]*$')

PARENT_TYPES = {"softwareSystem", "container", "deploymentEnvironment", "deploymentNode"}

@dataclass
class Scope:
    kind: str
    alias: str | None
    full: str | None
    depth: int


def strip_comment(line: str) -> str:
    in_quote = False
    escaped = False
    for i, ch in enumerate(line):
        if escaped:
            escaped = False
            continue
        if ch == "\\":
            escaped = True
            continue
        if ch == '"':
            in_quote = not in_quote
        if ch == "#" and not in_quote:
            return line[:i]
    return line


def quote_ok(line: str) -> bool:
    escaped = False
    count = 0
    for ch in line:
        if escaped:
            escaped = False
        elif ch == "\\":
            escaped = True
        elif ch == '"':
            count += 1
    return count % 2 == 0


def model_region(lines: list[str]) -> tuple[int, int]:
    start = next(i for i, line in enumerate(lines) if re.match(r'^\s*model\s*\{', line))
    depth = 0
    for i in range(start, len(lines)):
        code = strip_comment(lines[i])
        depth += code.count("{") - code.count("}")
        if i > start and depth == 0:
            return start, i
    raise ValueError("Unclosed model block")


def collect_aliases(lines: list[str], start: int, end: int):
    aliases: dict[str, tuple[str, int]] = {}
    short_counts: Counter[str] = Counter()
    scopes: list[Scope] = []
    # The scanned region starts immediately inside model { ... }.
    depth = 1
    errors: list[str] = []

    for lineno in range(start + 1, end):
        raw = lines[lineno]
        code = strip_comment(raw).strip()
        if not code:
            continue

        leading_closes = len(code) - len(code.lstrip("}"))
        effective_depth = depth - leading_closes
        while scopes and scopes[-1].depth > effective_depth:
            scopes.pop()

        match = ALIAS_RE.match(code)
        opens = code.count("{")
        closes = code.count("}")
        if match:
            alias, kind = match.groups()
            parent = next((s for s in reversed(scopes) if s.kind in PARENT_TYPES and s.full), None)
            if parent and kind not in {"deploymentEnvironment"}:
                full = f"{parent.full}.{alias}"
            else:
                full = alias
            if full in aliases:
                errors.append(f"L{lineno+1}: duplicate full identifier {full}")
            aliases[full] = (kind, lineno + 1)
            short_counts[alias] += 1
            aliases.setdefault(alias, (kind, lineno + 1))
            if opens > 0 and kind in PARENT_TYPES:
                scopes.append(Scope(kind, alias, full, depth + 1))

        depth += opens - closes
        while scopes and scopes[-1].depth > depth:
            scopes.pop()

    return aliases, short_counts, errors


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("workspace", type=Path)
    args = parser.parse_args()
    lines = args.workspace.read_text(encoding="utf-8").splitlines()
    errors: list[str] = []
    warnings: list[str] = []

    # Lexical checks.
    depth = 0
    for i, raw in enumerate(lines, 1):
        if not quote_ok(raw):
            errors.append(f"L{i}: unbalanced double quotes")
        code = strip_comment(raw)
        stripped = code.strip()
        if stripped == "{":
            errors.append(f"L{i}: opening brace must be on the preceding statement line")
        depth += code.count("{") - code.count("}")
        if depth < 0:
            errors.append(f"L{i}: unexpected closing brace")
            depth = 0
    if depth != 0:
        errors.append(f"Brace balance is {depth}, expected 0")

    try:
        m_start, m_end = model_region(lines)
    except Exception as exc:
        errors.append(str(exc))
        m_start, m_end = 0, 0

    aliases, short_counts, alias_errors = collect_aliases(lines, m_start, m_end)
    errors.extend(alias_errors)
    known = set(aliases)

    # Static model relationships.
    static_pairs: set[tuple[str, str]] = set()
    duplicate_pairs: defaultdict[tuple[str, str], list[int]] = defaultdict(list)
    for i in range(m_start + 1, m_end):
        code = strip_comment(lines[i])
        match = REL_RE.match(code)
        if not match:
            continue
        src, dst = match.groups()
        static_pairs.add((src, dst))
        duplicate_pairs[(src, dst)].append(i + 1)
        if src not in known:
            errors.append(f"L{i+1}: unknown relationship source {src}")
        if dst not in known:
            errors.append(f"L{i+1}: unknown relationship destination {dst}")
    for pair, locations in duplicate_pairs.items():
        if len(locations) > 1:
            warnings.append(f"Multiple static relationships {pair[0]} -> {pair[1]} at lines {locations}")

    # View keys and include identifiers.
    keys: defaultdict[str, list[int]] = defaultdict(list)
    in_views = False
    in_dynamic = False
    dynamic_depth = -1
    current_depth = 0
    for i, raw in enumerate(lines, 1):
        code = strip_comment(raw)
        stripped = code.strip()
        current_depth += code.count("{") - code.count("}")
        if re.match(r'^\s*views\s*\{', code):
            in_views = True
        if not in_views:
            continue

        # More reliable key extraction per view type.
        patterns = [
            r'^\s*systemLandscape\s+"([^"]+)"',
            r'^\s*systemContext\s+\S+\s+"([^"]+)"',
            r'^\s*container\s+\S+\s+"([^"]+)"',
            r'^\s*component\s+\S+\s+"([^"]+)"',
            r'^\s*dynamic\s+\S+\s+"([^"]+)"',
            r'^\s*deployment\s+\S+\s+\S+\s+"([^"]+)"',
            r'^\s*custom\s+"([^"]+)"',
        ]
        for pat in patterns:
            mm = re.match(pat, code)
            if mm:
                keys[mm.group(1)].append(i)
                if pat.startswith(r'^\s*dynamic'):
                    in_dynamic = True
                    dynamic_depth = current_depth
                break

        inc = INCLUDE_RE.match(code)
        if inc:
            # Skip view expressions and wildcard; inspect plain identifiers only.
            text = inc.group(1).strip()
            # Remove quoted strings if any (none expected here).
            for token in text.split():
                if token == "*" or token.startswith('"') or not TOKEN_RE.match(token):
                    continue
                if token not in known:
                    errors.append(f"L{i}: unknown include identifier {token}")

        # Dynamic relationship validation: lines with order prefix inside views.
        if re.match(r'^\s*[0-9A-Za-z_.-]+:\s*', code):
            rel = REL_RE.match(code)
            if rel:
                pair = rel.groups()
                if pair not in static_pairs:
                    errors.append(f"L{i}: dynamic relationship has no static model relationship: {pair[0]} -> {pair[1]}")
                if pair[0] not in known:
                    errors.append(f"L{i}: unknown dynamic source {pair[0]}")
                if pair[1] not in known:
                    errors.append(f"L{i}: unknown dynamic destination {pair[1]}")

    for key, locations in keys.items():
        if len(locations) > 1:
            errors.append(f"Duplicate view key {key} at lines {locations}")

    # Expected pack count.
    view_count = sum(len(v) for v in keys.values())
    if view_count != 41:
        warnings.append(f"View count is {view_count}; expected 41")

    # Report ambiguous short aliases; not an error because the workspace uses full paths.
    ambiguous = sorted(k for k, count in short_counts.items() if count > 1)
    if ambiguous:
        warnings.append("Ambiguous short aliases (full hierarchical identifiers required): " + ", ".join(ambiguous))

    print(f"Workspace: {args.workspace}")
    print(f"Known identifiers: {len(known)}")
    print(f"Static relationships: {len(static_pairs)}")
    print(f"View keys: {view_count}")
    if warnings:
        print("Warnings:")
        for warning in warnings:
            print(f"  - {warning}")
    if errors:
        print("Errors:")
        for error in errors:
            print(f"  - {error}")
        return 1
    print("Static consistency checks passed.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
