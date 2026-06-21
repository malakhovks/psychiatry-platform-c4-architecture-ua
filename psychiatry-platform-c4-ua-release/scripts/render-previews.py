#!/usr/bin/env python3
"""Generate supplementary Graphviz previews for all Structurizr views.

The Structurizr DSL remains the authoritative architecture source. These previews are
created to make the package immediately inspectable without a Structurizr server/CLI.
"""
from __future__ import annotations

from dataclasses import dataclass, field
from pathlib import Path
from collections import defaultdict
import argparse
import hashlib
import html
import re
import subprocess
import textwrap

try:
    import cairosvg
except ImportError:  # pragma: no cover - fallback handled at runtime
    cairosvg = None

from render_c1_presentation import render_view as render_c1_presentation_view

ALIAS_RE = re.compile(
    r'^\s*([A-Za-z_][A-Za-z0-9_]*)\s*=\s*'
    r'(person|softwareSystem|container|component|element|deploymentEnvironment|deploymentGroup|deploymentNode|infrastructureNode|softwareSystemInstance|containerInstance)\b'
)
REL_RE = re.compile(r'^\s*(?:([0-9A-Za-z_.-]+):\s*)?([A-Za-z_][A-Za-z0-9_.]*)\s*->\s*([A-Za-z_][A-Za-z0-9_.]*)\s*(?:"([^"]*)")?')
PARENT_TYPES = {"softwareSystem", "container", "deploymentEnvironment", "deploymentNode"}


@dataclass
class Element:
    ref: str
    short: str
    kind: str
    name: str
    description: str = ""
    technology: str = ""
    tags: set[str] = field(default_factory=set)
    parent: str | None = None
    instance_of: str | None = None


@dataclass
class Relationship:
    source: str
    destination: str
    description: str
    order: str | None = None
    line: int = 0


@dataclass
class View:
    kind: str
    key: str
    title: str
    description: str
    scope: str | None = None
    environment: str | None = None
    includes: list[str] = field(default_factory=list)
    steps: list[Relationship] = field(default_factory=list)


def quoted_strings(line: str) -> list[str]:
    return re.findall(r'"((?:[^"\\]|\\.)*)"', line)


def strip_comment(line: str) -> str:
    in_quote = False
    escaped = False
    for i, ch in enumerate(line):
        if escaped:
            escaped = False
        elif ch == "\\":
            escaped = True
        elif ch == '"':
            in_quote = not in_quote
        elif ch == "#" and not in_quote:
            return line[:i]
    return line


def find_block(lines: list[str], pattern: str) -> tuple[int, int]:
    start = next(i for i, line in enumerate(lines) if re.match(pattern, line))
    depth = 0
    for i in range(start, len(lines)):
        code = strip_comment(lines[i])
        depth += code.count("{") - code.count("}")
        if i > start and depth == 0:
            return start, i
    raise RuntimeError(f"Block not closed: {pattern}")


def parse_elements(lines: list[str], start: int, end: int):
    elements: dict[str, Element] = {}
    short_to_full: dict[str, str] = {}
    scopes: list[tuple[str, str, int]] = []  # kind, full ref, depth inside block
    depth = 1
    pending_custom: tuple[str, int] | None = None

    for idx in range(start + 1, end):
        raw = lines[idx]
        code = strip_comment(raw).strip()
        if not code:
            continue
        leading_closes = len(code) - len(code.lstrip("}"))
        effective_depth = depth - leading_closes
        while scopes and scopes[-1][2] > effective_depth:
            scopes.pop()

        match = ALIAS_RE.match(code)
        opens = code.count("{")
        closes = code.count("}")
        if match:
            alias, kind = match.groups()
            parent = next((s for s in reversed(scopes) if s[0] in PARENT_TYPES), None)
            full = f"{parent[1]}.{alias}" if parent and kind != "deploymentEnvironment" else alias
            qs = quoted_strings(code)
            name = alias
            desc = ""
            tech = ""
            tags: set[str] = set()
            instance_of = None
            if kind in {"person", "softwareSystem"}:
                if qs:
                    name = qs[0]
                if len(qs) > 1:
                    desc = qs[1]
                if len(qs) > 2:
                    tags = {t.strip() for t in qs[2].split(",") if t.strip()}
            elif kind in {"container", "component"}:
                if qs:
                    name = qs[0]
                if len(qs) > 1:
                    desc = qs[1]
                if len(qs) > 2:
                    tech = qs[2]
                if len(qs) > 3:
                    tags = {t.strip() for t in qs[3].split(",") if t.strip()}
            elif kind == "element":
                if qs:
                    name = qs[0]
                pending_custom = (full, depth + 1)
            elif kind == "deploymentEnvironment":
                name = qs[0] if qs else alias
            elif kind == "deploymentNode":
                name = qs[0] if qs else alias
                desc = qs[1] if len(qs) > 1 else ""
                tech = qs[2] if len(qs) > 2 else ""
                tags = {t.strip() for t in (qs[3] if len(qs) > 3 else "").split(",") if t.strip()}
            elif kind == "infrastructureNode":
                name = qs[0] if qs else alias
                desc = qs[1] if len(qs) > 1 else ""
                tech = qs[2] if len(qs) > 2 else ""
                tags = {t.strip() for t in (qs[3] if len(qs) > 3 else "").split(",") if t.strip()}
            elif kind in {"softwareSystemInstance", "containerInstance"}:
                rest = code.split(kind, 1)[1].strip()
                instance_of = rest.split()[0].strip()
                name = instance_of
            elif kind == "deploymentGroup":
                name = qs[0] if qs else alias

            parent_ref = parent[1] if parent else None
            elem = Element(full, alias, kind, name, desc, tech, tags, parent_ref, instance_of)
            elements[full] = elem
            short_to_full[alias] = full
            if opens > 0 and kind in PARENT_TYPES:
                scopes.append((kind, full, depth + 1))

        elif pending_custom and depth >= pending_custom[1]:
            full, custom_depth = pending_custom
            if code.startswith("description "):
                qs = quoted_strings(code)
                if qs:
                    elements[full].description = qs[0]
            elif code.startswith("tags "):
                qs = quoted_strings(code)
                if qs:
                    elements[full].tags = {t.strip() for t in qs[0].split(",") if t.strip()}

        depth += opens - closes
        while scopes and scopes[-1][2] > depth:
            scopes.pop()
        if pending_custom and depth < pending_custom[1]:
            pending_custom = None

    # Resolve instance names and parent references.
    for elem in elements.values():
        if elem.instance_of:
            target = elem.instance_of
            full_target = target if target in elements else short_to_full.get(target, target)
            elem.instance_of = full_target
            if full_target in elements:
                elem.name = elements[full_target].name
                elem.description = elements[full_target].description
                elem.technology = elements[full_target].technology
                elem.tags |= elements[full_target].tags
    return elements, short_to_full


def resolve(ref: str, elements: dict[str, Element], short_to_full: dict[str, str]) -> str:
    if ref in elements:
        return ref
    return short_to_full.get(ref, ref)


def parse_relationships(lines: list[str], start: int, end: int, elements, short_to_full):
    rels: list[Relationship] = []
    for idx in range(start + 1, end):
        code = strip_comment(lines[idx])
        m = REL_RE.match(code)
        if not m:
            continue
        order, src, dst, desc = m.groups()
        rels.append(Relationship(resolve(src, elements, short_to_full), resolve(dst, elements, short_to_full), desc or "", order, idx + 1))
    return rels


def parse_views(lines: list[str], views_start: int, views_end: int, elements, short_to_full):
    views: list[View] = []
    i = views_start + 1
    while i < views_end:
        code = strip_comment(lines[i]).strip()
        if not code or code.startswith("styles") or code.startswith("element ") or code.startswith("relationship "):
            i += 1
            continue
        kind = None
        key = None
        scope = None
        environment = None
        description = ""
        title = ""
        qs = quoted_strings(code)
        if code.startswith("systemLandscape "):
            kind = "systemLandscape"
            key = qs[0] if qs else None
            description = qs[1] if len(qs) > 1 else ""
        elif code.startswith("systemContext "):
            kind = "systemContext"
            parts = code.split()
            scope = resolve(parts[1], elements, short_to_full)
            key = qs[0] if qs else None
            description = qs[1] if len(qs) > 1 else ""
        elif code.startswith("container "):
            kind = "container"
            parts = code.split()
            scope = resolve(parts[1], elements, short_to_full)
            key = qs[0] if qs else None
            description = qs[1] if len(qs) > 1 else ""
        elif code.startswith("component "):
            kind = "component"
            parts = code.split()
            scope = resolve(parts[1], elements, short_to_full)
            key = qs[0] if qs else None
            description = qs[1] if len(qs) > 1 else ""
        elif code.startswith("dynamic "):
            kind = "dynamic"
            parts = code.split()
            scope = resolve(parts[1], elements, short_to_full) if parts[1] != "*" else "*"
            key = qs[0] if qs else None
            description = qs[1] if len(qs) > 1 else ""
        elif code.startswith("deployment "):
            kind = "deployment"
            parts = code.split()
            scope = parts[1]
            environment = resolve(parts[2], elements, short_to_full)
            key = qs[0] if qs else None
            description = qs[1] if len(qs) > 1 else ""
        elif code.startswith("custom "):
            kind = "custom"
            key = qs[0] if qs else None
            title = qs[1] if len(qs) > 1 else ""
            description = qs[2] if len(qs) > 2 else ""

        if not kind or not key or "{" not in code:
            i += 1
            continue
        start_depth = code.count("{") - code.count("}")
        depth = start_depth
        includes: list[str] = []
        steps: list[Relationship] = []
        j = i + 1
        while j < views_end and depth > 0:
            inner = strip_comment(lines[j]).strip()
            if inner.startswith("title "):
                q = quoted_strings(inner)
                if q:
                    title = q[0]
            elif inner.startswith("include "):
                for token in inner[len("include "):].split():
                    if token != "*":
                        includes.append(resolve(token, elements, short_to_full))
                    else:
                        includes.append("*")
            else:
                rm = REL_RE.match(inner)
                if kind == "dynamic" and rm and rm.group(1):
                    order, src, dst, desc = rm.groups()
                    steps.append(Relationship(resolve(src, elements, short_to_full), resolve(dst, elements, short_to_full), desc or "", order, j + 1))
            depth += inner.count("{") - inner.count("}")
            j += 1
        views.append(View(kind, key, title or key, description, scope, environment, includes, steps))
        i = j
    return views


def gv_id(ref: str) -> str:
    return "n_" + hashlib.sha1(ref.encode("utf-8")).hexdigest()[:12]


def wrap(text: str, width: int = 34) -> str:
    if not text:
        return ""
    return "<BR/>".join(html.escape(line) for line in textwrap.wrap(text, width=width, break_long_words=False, break_on_hyphens=False))


def type_label(elem: Element) -> str:
    labels = {
        "person": "Особа",
        "softwareSystem": "Програмна система",
        "container": "Контейнер",
        "component": "Компонент",
        "element": "Логічний елемент",
        "deploymentNode": "Вузол розгортання",
        "infrastructureNode": "Інфраструктура",
        "softwareSystemInstance": "Екземпляр системи",
        "containerInstance": "Екземпляр контейнера",
    }
    if "DataStore" in elem.tags:
        return "Сховище даних"
    return labels.get(elem.kind, elem.kind)


def node_style(elem: Element) -> tuple[str, str, str]:
    bg, fg, shape = "#F4F7FA", "#18324A", "box"
    tags = elem.tags
    if elem.kind == "person":
        bg, fg, shape = "#084C61", "#FFFFFF", "box"
    if "Clinician" in tags:
        bg, fg = "#6C4AB6", "#FFFFFF"
    if "ConsultingPhysician" in tags:
        bg, fg = "#1565C0", "#FFFFFF"
    if "Methodologist" in tags:
        bg, fg = "#8A5A00", "#FFFFFF"
    if "Administrator" in tags:
        bg, fg = "#4A5568", "#FFFFFF"
    if "PlatformSystem" in tags:
        bg, fg = "#0A6EBD", "#FFFFFF"
    if "ExternalSystem" in tags:
        bg, fg = "#E9EEF4", "#263238"
    if "CrisisSystem" in tags:
        bg, fg = "#C92A2A", "#FFFFFF"
    if "PatientUI" in tags:
        bg, fg = "#0B7285", "#FFFFFF"
    if "ClinicianUI" in tags:
        bg, fg = "#6C4AB6", "#FFFFFF"
    if "AdminUI" in tags:
        bg, fg = "#8A5A00", "#FFFFFF"
    if "CoreClinicalService" in tags:
        bg, fg = "#2B6CB0", "#FFFFFF"
    if "AIService" in tags or "AISystem" in tags:
        bg, fg = "#6741D9", "#FFFFFF"
    if "MeasurementService" in tags:
        bg, fg = "#0F766E", "#FFFFFF"
    if "IntegrationService" in tags:
        bg, fg = "#3B5BDB", "#FFFFFF"
    if "WorkflowService" in tags:
        bg, fg = "#B7791F", "#FFFFFF"
    if "AuditService" in tags:
        bg, fg = "#4A5568", "#FFFFFF"
    if "EventBus" in tags:
        bg, fg, shape = "#C05621", "#FFFFFF", "cylinder"
    if "DataStore" in tags:
        bg, fg, shape = "#EDF2F7", "#1A202C", "cylinder"
    if "SensitiveDataStore" in tags:
        bg, fg, shape = "#FFE3E3", "#5C1A1A", "cylinder"
    if "CodeElement" in tags:
        bg, fg, shape = "#FFF9DB", "#4A3B00", "component"
    if "Rule" in tags:
        bg, fg = "#FFE3E3", "#5C1A1A"
    if "AggregateRoot" in tags:
        bg, fg = "#FFE8A1", "#4A3B00"
    if elem.kind == "infrastructureNode":
        bg, fg, shape = "#4A5568", "#FFFFFF", "hexagon"
    return bg, fg, shape


def node_dot(elem: Element, font_size: int = 12) -> str:
    bg, fg, shape = node_style(elem)
    meta = type_label(elem)
    if elem.technology:
        meta += f" · {elem.technology}"
    border = "#C92A2A" if "SafetyCritical" in elem.tags else "#486581"
    pen = "3" if "SafetyCritical" in elem.tags or "AggregateRoot" in elem.tags else "1.5"
    label = f'<<B>{wrap(elem.name, 28)}</B><BR/><FONT POINT-SIZE="{max(font_size-2,8)}">[{html.escape(meta)}]</FONT>>'
    return f'{gv_id(elem.ref)} [label={label}, shape={shape}, style="rounded,filled", fillcolor="{bg}", fontcolor="{fg}", color="{border}", penwidth={pen}];'


SLIDE_VIEW_KEYS = {"C1-01-Landscape", "C1-03-PatientContext", "C1-04-ClinicianContext"}


def node_dot_slide(elem: Element, font_size: int = 10, width: float = 1.85) -> str:
    """Compact C4 node used by 16:9 presentation renderings."""
    bg, fg, shape = node_style(elem)
    meta = type_label(elem)
    border = "#0D47A1" if "ConsultingPhysician" in elem.tags else ("#C92A2A" if "SafetyCritical" in elem.tags else "#486581")
    pen = "2.2" if "ConsultingPhysician" in elem.tags or "SafetyCritical" in elem.tags else "1.35"
    name_width = 22 if elem.kind == "person" else 25
    label = f'<<B>{wrap(elem.name, name_width)}</B><BR/><FONT POINT-SIZE="{max(font_size-2,7)}">[{html.escape(meta)}]</FONT>>'
    return (f'{gv_id(elem.ref)} [label={label}, shape={shape}, style="rounded,filled", '
            f'fillcolor="{bg}", fontcolor="{fg}", color="{border}", penwidth={pen}, width={width}, height=0.48];')


def _order_rank(refs: list[str]) -> list[str]:
    lines = ["{ rank=same;"]
    lines.extend(gv_id(ref) + ";" for ref in refs)
    lines.append("}")
    for a, b in zip(refs, refs[1:]):
        lines.append(f'{gv_id(a)} -> {gv_id(b)} [style=invis, weight=100, constraint=false];')
    return lines


def _compact_relationship_label(view_key: str, source: str, destination: str, description: str) -> str:
    labels = {
        "patient": "Скринінг і супровід",
        "psychiatrist": "Ризик і траєкторія",
        "psychologist": "Психологічне оцінювання",
        "nurse": "Координація",
        "crisisSpecialist": "Кризова ескалація",
        "cardiologist": "ЕКГ і коморбідність",
        "rehabilitationSpecialist": "Реабілітація",
        "neurologist": "Неврологічна оцінка",
        "pediatrician": "Вікова оцінка",
        "researcher": "Знеособлена аналітика",
        "securityOfficer": "Безпека й аудит",
        "identityProvider": "Автентифікація",
        "ehrSystem": "Клінічні дані",
        "terminologySystem": "Коди й термінології",
        "protocolRepository": "Протоколи та знання",
        "algorithmSourceRepository": "Вихідні алгоритми",
        "notificationProvider": "Повідомлення",
        "calendarProvider": "Календар і візити",
        "telemedicinePlatform": "Телемедицина",
        "emergencySystem": "Екстрена допомога",
        "deviceEcosystem": "Біосигнали",
        "pacsSystem": "Медичні зображення",
        "externalAIModels": "Контрольовані моделі ШІ",
    }
    if source == "platform":
        return labels.get(destination, description)
    return labels.get(source, description)


def presentation_dot(view: View, elements: dict[str, Element], relationships: list[Relationship]) -> str:
    """Build dense but legible 16:9 C1 diagrams for slide presentations."""
    included = view_elements(view, elements)
    configs = {
        "C1-01-Landscape": {
            "left": [
                ["patient", "psychiatrist", "psychologist", "nurse", "cardiologist"],
                ["rehabilitationSpecialist", "neurologist", "pediatrician", "researcher", "securityOfficer"],
            ],
            "right": [
                ["identityProvider", "ehrSystem", "terminologySystem", "protocolRepository", "algorithmSourceRepository", "notificationProvider"],
                ["calendarProvider", "telemedicinePlatform", "emergencySystem", "deviceEcosystem", "pacsSystem", "externalAIModels"],
            ],
            "left_label": "Користувачі та фахівці",
            "right_label": "Зовнішня цифрова екосистема",
            "node_width": 1.72,
            "font_size": 9,
            "ranksep": 0.52,
            "nodesep": 0.12,
        },
        "C1-03-PatientContext": {
            "left": [["patient", "psychiatrist"]],
            "right": [
                ["identityProvider", "notificationProvider", "calendarProvider", "telemedicinePlatform"],
                ["emergencySystem", "deviceEcosystem", "externalAIModels"],
            ],
            "left_label": "Пацієнт і лікар",
            "right_label": "Сервіси підтримки",
            "node_width": 2.05,
            "font_size": 11,
            "ranksep": 0.82,
            "nodesep": 0.28,
        },
        "C1-04-ClinicianContext": {
            "left": [
                ["psychiatrist", "psychologist", "nurse", "crisisSpecialist"],
                ["cardiologist", "rehabilitationSpecialist", "neurologist", "pediatrician"],
            ],
            "right": [
                ["identityProvider", "ehrSystem", "terminologySystem", "protocolRepository", "telemedicinePlatform"],
                ["emergencySystem", "deviceEcosystem", "pacsSystem", "externalAIModels"],
            ],
            "left_label": "Мультидисциплінарна команда",
            "right_label": "Клінічні та цифрові сервіси",
            "node_width": 1.82,
            "font_size": 9,
            "ranksep": 0.54,
            "nodesep": 0.15,
        },
    }
    cfg = configs[view.key]
    left_cols = [[ref for ref in col if ref in included] for col in cfg["left"]]
    right_cols = [[ref for ref in col if ref in included] for col in cfg["right"]]
    platform_ref = "platform"
    title_size = 17 if view.key == "C1-03-PatientContext" else 15
    desc_width = 145 if view.key == "C1-03-PatientContext" else 165
    lines = [
        "digraph G {",
        ('graph [rankdir=LR, newrank=true, compound=true, bgcolor="white", pad="0.20", margin="0", '
         f'nodesep="{cfg["nodesep"]}", ranksep="{cfg["ranksep"]}", splines=polyline, overlap=false, outputorder=edgesfirst, '
         'fontname="DejaVu Sans", labelloc=t, labeljust=c, size="13.333,7.5!", ratio=fill];'),
        f'node [fontname="DejaVu Sans", fontsize={cfg["font_size"]}, margin="0.10,0.06"];',
        'edge [fontname="DejaVu Sans", fontsize=7.5, color="#486581", fontcolor="#334E68", penwidth=1.15, arrowsize=0.62];',
        f'label=<<B><FONT POINT-SIZE="{title_size}">{html.escape(view.title)}</FONT></B><BR/><FONT POINT-SIZE="9">{wrap(view.description, desc_width)}</FONT>>;',
    ]

    # Roles and users boundary.
    lines.append('subgraph cluster_roles {')
    lines.append(f'label=<<B>{html.escape(cfg["left_label"])}</B>>; color="#CBD5E0"; fontcolor="#334E68"; fontsize=11; penwidth=1.2; style="rounded"; margin=10;')
    for col in left_cols:
        for ref in col:
            lines.append(node_dot_slide(elements[ref], cfg["font_size"], cfg["node_width"]))
        lines.extend(_order_rank(col))
    lines.append('}')

    # Main platform.
    lines.append(node_dot_slide(elements[platform_ref], 12 if view.key == "C1-03-PatientContext" else 11, 2.35))

    # External services boundary.
    lines.append('subgraph cluster_external {')
    lines.append(f'label=<<B>{html.escape(cfg["right_label"])}</B>>; color="#CBD5E0"; fontcolor="#334E68"; fontsize=11; penwidth=1.2; style="rounded"; margin=10;')
    for col in right_cols:
        for ref in col:
            lines.append(node_dot_slide(elements[ref], cfg["font_size"], cfg["node_width"]))
        lines.extend(_order_rank(col))
    lines.append('}')

    # Invisible rank skeleton creates two columns on each side.
    left_anchors = [col[0] for col in left_cols if col]
    right_anchors = [col[0] for col in right_cols if col]
    if len(left_anchors) == 2:
        lines.append(f'{gv_id(left_anchors[0])} -> {gv_id(left_anchors[1])} [style=invis, weight=200, minlen=1];')
    if left_anchors:
        lines.append(f'{gv_id(left_anchors[-1])} -> {gv_id(platform_ref)} [style=invis, weight=250, minlen=2];')
    if right_anchors:
        lines.append(f'{gv_id(platform_ref)} -> {gv_id(right_anchors[0])} [style=invis, weight=250, minlen=2];')
    if len(right_anchors) == 2:
        lines.append(f'{gv_id(right_anchors[0])} -> {gv_id(right_anchors[1])} [style=invis, weight=200, minlen=1];')

    # Draw only relationships represented by the view; use concise slide labels.
    seen: set[tuple[str, str]] = set()
    for rel in relationships:
        if rel.source not in included or rel.destination not in included:
            continue
        if platform_ref not in {rel.source, rel.destination}:
            continue
        key = (rel.source, rel.destination)
        if key in seen:
            continue
        seen.add(key)
        compact = _compact_relationship_label(view.key, rel.source, rel.destination, rel.description)
        # Full edge labels are retained in DSL; presentation renderings use short labels.
        lines.append(
            f'{gv_id(rel.source)} -> {gv_id(rel.destination)} '
            f'[constraint=false, label=<{wrap(compact, 22)}>];'
        )
    lines.append("}")
    return "\n".join(lines) + "\n"


def _svg_text_lines(text: str, max_chars: int) -> list[str]:
    return textwrap.wrap(text, width=max_chars, break_long_words=False, break_on_hyphens=False) or [""]


def _svg_text(x: float, y: float, text: str, size: int, *, weight: int = 400,
              fill: str = "#18324A", anchor: str = "middle") -> str:
    return (f'<text x="{x:.1f}" y="{y:.1f}" text-anchor="{anchor}" '
            f'font-family="DejaVu Sans, Arial, sans-serif" font-size="{size}" '
            f'font-weight="{weight}" fill="{fill}">{html.escape(text)}</text>')


def _svg_multiline(x: float, center_y: float, lines: list[str], size: int, *,
                   weight: int = 400, fill: str = "#18324A", line_height: float | None = None) -> str:
    lh = line_height or size * 1.12
    start_y = center_y - (len(lines) - 1) * lh / 2
    tspans = []
    for idx, line in enumerate(lines):
        dy = 0 if idx == 0 else lh
        tspans.append(f'<tspan x="{x:.1f}" dy="{dy:.1f}">{html.escape(line)}</tspan>')
    return (f'<text x="{x:.1f}" y="{start_y:.1f}" text-anchor="middle" '
            f'font-family="DejaVu Sans, Arial, sans-serif" font-size="{size}" '
            f'font-weight="{weight}" fill="{fill}">' + "".join(tspans) + '</text>')


def _svg_box(elem: Element, x: float, y: float, w: float, h: float,
             *, name_size: int = 21, meta_size: int = 14) -> str:
    bg, fg, _ = node_style(elem)
    border = "#0D47A1" if "ConsultingPhysician" in elem.tags else ("#C92A2A" if "CrisisSystem" in elem.tags else "#486581")
    stroke_width = 3 if "ConsultingPhysician" in elem.tags else 2.2
    max_chars = max(10, int(w / (name_size * 0.75)))
    lines = _svg_text_lines(elem.name, max_chars)
    if len(lines) > 2 and name_size > 16:
        name_size -= 2
        max_chars = max(10, int(w / (name_size * 0.75)))
        lines = _svg_text_lines(elem.name, max_chars)
    name_center = y + h / 2 - (meta_size * 0.45 if len(lines) <= 2 else meta_size * 0.15)
    parts = [
        f'<rect x="{x:.1f}" y="{y:.1f}" width="{w:.1f}" height="{h:.1f}" rx="18" '
        f'fill="{bg}" stroke="{border}" stroke-width="{stroke_width}"/>',
        _svg_multiline(x + w/2, name_center, lines, name_size, weight=700, fill=fg),
        _svg_text(x + w/2, y + h - 13, f'[{type_label(elem)}]', meta_size, fill=fg),
    ]
    return "".join(parts)


def _svg_group(x: float, y: float, w: float, h: float, label: str) -> str:
    return (
        f'<rect x="{x:.1f}" y="{y:.1f}" width="{w:.1f}" height="{h:.1f}" rx="24" '
        'fill="#FFFFFF" stroke="#CBD5E0" stroke-width="2.5"/>'
        + _svg_text(x+w/2, y+31, label, 22, weight=700, fill="#334E68")
    )


def _grid_positions(x: float, y: float, w: float, h: float, rows: int, cols: int,
                    *, header: float = 58, gap_x: float = 24, gap_y: float = 18,
                    box_h: float = 78) -> list[tuple[float, float, float, float]]:
    usable_h = h - header - 28
    total_boxes_h = rows * box_h + max(rows-1, 0) * gap_y
    start_y = y + header + max(0, (usable_h - total_boxes_h) / 2)
    box_w = (w - 34 - (cols-1)*gap_x) / cols
    start_x = x + 17
    out = []
    for r in range(rows):
        for c in range(cols):
            out.append((start_x + c*(box_w+gap_x), start_y + r*(box_h+gap_y), box_w, box_h))
    return out


def slide_svg(view: View, elements: dict[str, Element]) -> str:
    """Create a precise 1920x1080 presentation rendering for selected C1 views."""
    configs = {
        "C1-01-Landscape": {
            "left": ["patient", "rehabilitationSpecialist", "psychiatrist", "neurologist", "psychologist", "pediatrician", "nurse", "researcher", "cardiologist", "securityOfficer"],
            "right": ["identityProvider", "calendarProvider", "ehrSystem", "telemedicinePlatform", "terminologySystem", "emergencySystem", "protocolRepository", "deviceEcosystem", "algorithmSourceRepository", "pacsSystem", "notificationProvider", "externalAIModels"],
            "left_group": (34, 145, 625, 810, 5, 2, "Користувачі та фахівці"),
            "right_group": (1261, 145, 625, 810, 6, 2, "Зовнішня цифрова екосистема"),
            "platform": (755, 458, 410, 132),
            "left_relation": "Взаємодія",
            "right_relation": "Інтеграції",
            "subtitle": "Платформа поєднує пацієнта, мультидисциплінарну команду та зовнішні клінічні й цифрові сервіси.",
        },
        "C1-03-PatientContext": {
            "left": ["patient", "psychiatrist"],
            "right": ["identityProvider", "notificationProvider", "calendarProvider", "telemedicinePlatform", "emergencySystem", "deviceEcosystem", "externalAIModels"],
            "left_group": (55, 300, 370, 470, 2, 1, "Пацієнт і лікар"),
            "right_group": (1225, 185, 650, 710, 4, 2, "Сервіси підтримки"),
            "platform": (665, 445, 430, 142),
            "left_relation": "Скринінг і супровід",
            "right_relation": "Інтеграції",
            "subtitle": "Компактний контекст взаємодії пацієнта і лікаря: від скринінгу та вимірювань до консультації й маршрутизації.",
        },
        "C1-04-ClinicianContext": {
            "left": ["psychiatrist", "cardiologist", "psychologist", "rehabilitationSpecialist", "nurse", "neurologist", "crisisSpecialist", "pediatrician"],
            "right": ["identityProvider", "emergencySystem", "ehrSystem", "deviceEcosystem", "terminologySystem", "pacsSystem", "protocolRepository", "externalAIModels", "telemedicinePlatform"],
            "left_group": (34, 190, 655, 730, 4, 2, "Мультидисциплінарна команда"),
            "right_group": (1231, 170, 655, 770, 5, 2, "Клінічні та цифрові сервіси"),
            "platform": (755, 455, 410, 142),
            "left_relation": "Клінічна оцінка",
            "right_relation": "Інтеграції",
            "subtitle": "ШІ-асистент підтримує психіатричну, психологічну, соматичну, неврологічну, педіатричну та реабілітаційну оцінку.",
        },
    }
    cfg = configs[view.key]
    W, H = 1920, 1080
    lx, ly, lw, lh, lrows, lcols, llabel = cfg["left_group"]
    rx, ry, rw, rh, rrows, rcols, rlabel = cfg["right_group"]
    px, py, pw, ph = cfg["platform"]
    parts = [
        f'<svg xmlns="http://www.w3.org/2000/svg" width="{W}" height="{H}" viewBox="0 0 {W} {H}">',
        '<defs><marker id="arrow" markerWidth="12" markerHeight="12" refX="10" refY="5" orient="auto" markerUnits="strokeWidth"><path d="M0,0 L10,5 L0,10 z" fill="#486581"/></marker></defs>',
        '<rect x="0" y="0" width="1920" height="1080" fill="#FFFFFF"/>',
        _svg_text(W/2, 52, view.title, 34, weight=700, fill="#111827"),
        _svg_text(W/2, 88, cfg["subtitle"], 18, fill="#334E68"),
        _svg_group(lx, ly, lw, lh, llabel),
        _svg_group(rx, ry, rw, rh, rlabel),
    ]

    l_positions = _grid_positions(lx, ly, lw, lh, lrows, lcols, box_h=86 if view.key == "C1-03-PatientContext" else 78)
    r_positions = _grid_positions(rx, ry, rw, rh, rrows, rcols, box_h=84)
    left_centers = []
    right_centers = []
    for ref, pos in zip(cfg["left"], l_positions):
        x, y, w, h = pos
        elem = elements[ref]
        parts.append(_svg_box(elem, x, y, w, h, name_size=22 if view.key == "C1-03-PatientContext" else 18, meta_size=13))
        left_centers.append((x+w, y+h/2))
    for ref, pos in zip(cfg["right"], r_positions):
        x, y, w, h = pos
        elem = elements[ref]
        parts.append(_svg_box(elem, x, y, w, h, name_size=18 if view.key != "C1-03-PatientContext" else 19, meta_size=12))
        right_centers.append((x, y+h/2))

    # Platform node.
    parts.append(_svg_box(elements["platform"], px, py, pw, ph, name_size=24, meta_size=15))
    line_style = 'fill="none" stroke="#486581" stroke-width="3" stroke-linecap="round" stroke-linejoin="round"'

    # Presentation-level group relationships. Individual C4 relationships remain in the DSL.
    arrow_y = py + ph / 2
    parts.append(f'<line x1="{lx+lw}" y1="{arrow_y}" x2="{px}" y2="{arrow_y}" {line_style} marker-end="url(#arrow)"/>')
    parts.append(_svg_multiline((lx+lw+px)/2, arrow_y-30, _svg_text_lines(cfg["left_relation"], 22), 14, weight=600, fill="#334E68"))
    parts.append(f'<line x1="{px+pw}" y1="{arrow_y}" x2="{rx}" y2="{arrow_y}" {line_style} marker-end="url(#arrow)"/>')
    parts.append(_svg_multiline((px+pw+rx)/2, arrow_y-30, _svg_text_lines(cfg["right_relation"], 22), 14, weight=600, fill="#334E68"))

    parts.append(_svg_text(W/2, 1038, "Детальні описи зв’язків, повноважень і потоків даних наведено у Structurizr DSL.", 15, fill="#64748B"))
    parts.append('</svg>')
    return "".join(parts)


def render_slide(view: View, elements: dict[str, Element], dot_path: Path, svg_path: Path, png_path: Path):
    # Presentation-specific renderer performs metric-based text fitting and ensures that
    # every label remains inside its assigned figure/text area.
    dot_path.write_text(
        '// Презентаційне SVG-подання генерується scripts/render_c1_presentation.py; '
        'Structurizr DSL залишається авторитетним джерелом архітектурної моделі.\n',
        encoding='utf-8',
    )
    svg_text, _checked = render_c1_presentation_view(view.key)
    svg_path.write_text(svg_text, encoding='utf-8')
    if cairosvg is not None:
        cairosvg.svg2png(
            bytestring=svg_text.encode('utf-8'),
            write_to=str(png_path),
            output_width=1920,
            output_height=1080,
        )
    else:
        subprocess.run(
            [
                "inkscape", str(svg_path), "--export-type=png",
                f"--export-filename={png_path}", "--export-width=1920", "--export-height=1080",
            ],
            check=True,
        )


def view_elements(view: View, elements: dict[str, Element]) -> set[str]:
    if view.kind == "dynamic":
        return {r.source for r in view.steps} | {r.destination for r in view.steps}
    if view.kind == "deployment":
        env = view.environment or ""
        return {ref for ref in elements if ref == env or ref.startswith(env + ".")}
    if "*" in view.includes:
        return set(elements)
    return {ref for ref in view.includes if ref in elements}


def static_dot(view: View, elements: dict[str, Element], relationships: list[Relationship]) -> str:
    included = view_elements(view, elements)
    large = len(included) > 28
    font_size = 10 if large else 12
    ranksep = 1.25 if large else 1.0
    nodesep = 0.6 if large else 0.45
    # Dense component/custom views are substantially more readable top-to-bottom.
    rankdir = "TB" if view.kind in {"component", "custom"} or large else "LR"
    lines = [
        "digraph G {",
        'graph [rankdir=%s, bgcolor="white", pad="0.35", nodesep="%.2f", ranksep="%.2f", splines=polyline, fontname="DejaVu Sans", labelloc=t, labeljust=l];' % (rankdir, nodesep, ranksep),
        'node [fontname="DejaVu Sans", fontsize=%d, margin="0.14,0.09"];' % font_size,
        'edge [fontname="DejaVu Sans", fontsize=%d, color="#486581", fontcolor="#334E68", penwidth=1.4, arrowsize=0.8];' % max(font_size-1, 8),
        f'label=<<B>{html.escape(view.title)}</B><BR/><FONT POINT-SIZE="{font_size}">{wrap(view.description, 90)}</FONT>>;',
    ]

    # C4 boundary for container/component views.
    clustered: set[str] = set()
    if view.kind == "container" and view.scope in elements:
        children = {ref for ref in included if elements[ref].parent == view.scope}
        if children:
            lines.append('subgraph cluster_scope {')
            lines.append(f'label=<<B>{html.escape(elements[view.scope].name)}</B>>; color="#0A6EBD"; penwidth=2.2; style="rounded";')
            for ref in sorted(children):
                lines.append(node_dot(elements[ref], font_size))
                clustered.add(ref)
            lines.append("}")
    elif view.kind == "component" and view.scope in elements:
        children = {ref for ref in included if elements[ref].parent == view.scope}
        if children:
            lines.append('subgraph cluster_scope {')
            lines.append(f'label=<<B>{html.escape(elements[view.scope].name)}</B>>; color="#486581"; penwidth=2.2; style="rounded";')
            for ref in sorted(children):
                lines.append(node_dot(elements[ref], font_size))
                clustered.add(ref)
            lines.append("}")

    for ref in sorted(included):
        if ref in clustered:
            continue
        elem = elements[ref]
        if elem.kind in {"deploymentEnvironment", "deploymentNode", "containerInstance", "softwareSystemInstance", "infrastructureNode", "deploymentGroup"}:
            continue
        lines.append(node_dot(elem, font_size))

    seen_edges: set[tuple[str, str, str]] = set()
    for rel in relationships:
        if rel.source not in included or rel.destination not in included:
            continue
        if rel.source not in elements or rel.destination not in elements:
            continue
        if elements[rel.source].kind in {"deploymentNode", "infrastructureNode", "containerInstance", "softwareSystemInstance"}:
            continue
        key = (rel.source, rel.destination, rel.description)
        if key in seen_edges:
            continue
        seen_edges.add(key)
        desc = wrap(rel.description, 38)
        label = f' label=<{desc}>' if desc else ""
        lines.append(f'{gv_id(rel.source)} -> {gv_id(rel.destination)} [{label}];')
    lines.append("}")
    return "\n".join(lines) + "\n"


def dynamic_dot(view: View, elements: dict[str, Element]) -> str:
    lines = [
        "digraph G {",
        'graph [rankdir=TB, bgcolor="white", pad="0.35", nodesep="0.25", ranksep="0.30", fontname="DejaVu Sans", labelloc=t, labeljust=l];',
        'node [fontname="DejaVu Sans", fontsize=12, shape=box, style="rounded,filled", fillcolor="#F4F7FA", color="#486581", margin="0.16,0.10"];',
        'edge [color="#7B8794", penwidth=1.2, arrowsize=0.7];',
        f'label=<<B>{html.escape(view.title)}</B><BR/><FONT POINT-SIZE="11">{wrap(view.description, 90)}</FONT>>;',
    ]
    participant_refs = []
    for step in view.steps:
        for ref in (step.source, step.destination):
            if ref not in participant_refs:
                participant_refs.append(ref)
    lines.append('{ rank=same;')
    for ref in participant_refs:
        elem = elements.get(ref)
        if not elem:
            continue
        bg, fg, _ = node_style(elem)
        lines.append(f'p_{gv_id(ref)} [label=<<B>{wrap(elem.name, 22)}</B>>, fillcolor="{bg}", fontcolor="{fg}", color="#486581", shape=box];')
    lines.append('}')
    previous = None
    for index, step in enumerate(view.steps, 1):
        src = elements.get(step.source)
        dst = elements.get(step.destination)
        src_name = src.name if src else step.source
        dst_name = dst.name if dst else step.destination
        order = step.order or str(index)
        label = f'< <B>{html.escape(order)}.</B> {wrap(src_name, 28)} → {wrap(dst_name, 28)}<BR/><FONT POINT-SIZE="10">{wrap(step.description, 72)}</FONT> >'
        node_id = f'step_{index:02d}'
        lines.append(f'{node_id} [label={label}, fillcolor="#FFFFFF", color="#486581", penwidth=1.5];')
        if previous:
            lines.append(f'{previous} -> {node_id};')
        previous = node_id
    lines.append("}")
    return "\n".join(lines) + "\n"


def deployment_dot(view: View, elements: dict[str, Element], relationships: list[Relationship]) -> str:
    env = view.environment or ""
    env_elem = elements.get(env)
    lines = [
        "digraph G {",
        'graph [rankdir=LR, compound=true, bgcolor="white", pad="0.35", nodesep="0.55", ranksep="0.95", splines=polyline, fontname="DejaVu Sans", labelloc=t, labeljust=l];',
        'node [fontname="DejaVu Sans", fontsize=10, margin="0.12,0.08"];',
        'edge [fontname="DejaVu Sans", fontsize=8, color="#486581", fontcolor="#334E68", penwidth=1.2, arrowsize=0.7];',
        f'label=<<B>{html.escape(view.title)}</B><BR/><FONT POINT-SIZE="10">{wrap(view.description, 90)}</FONT>>;',
    ]
    children: defaultdict[str, list[str]] = defaultdict(list)
    for ref, elem in elements.items():
        if elem.parent:
            children[elem.parent].append(ref)

    def render_parent(parent_ref: str, level: int = 0):
        for ref in sorted(children.get(parent_ref, [])):
            elem = elements[ref]
            if elem.kind == "deploymentNode":
                cid = "cluster_" + gv_id(ref)
                lines.append(f'subgraph {cid} {{')
                meta = f" · {elem.technology}" if elem.technology else ""
                lines.append(f'label=<<B>{html.escape(elem.name)}</B><BR/><FONT POINT-SIZE="9">{html.escape(meta.lstrip(" ·"))}</FONT>>; color="#718096"; style="rounded,dashed"; penwidth=1.5;')
                render_parent(ref, level + 1)
                lines.append("}")
            elif elem.kind in {"containerInstance", "softwareSystemInstance", "infrastructureNode"}:
                lines.append(node_dot(elem, 10))
    render_parent(env)

    # Explicit deployment relationships and selected auto-derived instance relationships.
    dep_refs = {ref for ref in elements if ref.startswith(env + ".")}
    edge_keys: set[tuple[str, str]] = set()
    for rel in relationships:
        if rel.source in dep_refs and rel.destination in dep_refs:
            if rel.source in elements and rel.destination in elements:
                if elements[rel.source].kind in {"containerInstance", "softwareSystemInstance", "infrastructureNode"} and elements[rel.destination].kind in {"containerInstance", "softwareSystemInstance", "infrastructureNode"}:
                    key = (rel.source, rel.destination)
                    if key not in edge_keys:
                        edge_keys.add(key)
                        lines.append(f'{gv_id(rel.source)} -> {gv_id(rel.destination)} [label=<{wrap(rel.description, 30)}>];')

    # Map container/system instances and reproduce high-value structural dependencies.
    instances_by_model: defaultdict[str, list[str]] = defaultdict(list)
    for ref in dep_refs:
        elem = elements[ref]
        if elem.instance_of:
            instances_by_model[elem.instance_of].append(ref)
    for rel in relationships:
        if rel.source not in instances_by_model or rel.destination not in instances_by_model:
            continue
        for src_inst in instances_by_model[rel.source]:
            for dst_inst in instances_by_model[rel.destination]:
                key = (src_inst, dst_inst)
                if key in edge_keys:
                    continue
                edge_keys.add(key)
                lines.append(f'{gv_id(src_inst)} -> {gv_id(dst_inst)} [label=<{wrap(rel.description, 26)}>];')
    lines.append("}")
    return "\n".join(lines) + "\n"


def render(dot_text: str, dot_path: Path, svg_path: Path, png_path: Path):
    dot_path.write_text(dot_text, encoding="utf-8")
    subprocess.run(["dot", "-Tsvg", str(dot_path), "-o", str(svg_path)], check=True)
    subprocess.run(["dot", "-Tpng", "-Gdpi=150", str(dot_path), "-o", str(png_path)], check=True)


def build_index(views: list[View], out_root: Path):
    rows = []
    for view in views:
        rows.append(
            f'<tr><td><code>{html.escape(view.key)}</code></td><td>{html.escape(view.title)}</td>'
            f'<td>{html.escape(view.kind)}</td><td><a href="svg/{view.key}.svg">SVG</a></td>'
            f'<td><a href="png/{view.key}.png">PNG</a></td></tr>'
        )
    page = f'''<!doctype html>
<html lang="uk"><head><meta charset="utf-8"><title>C4 — психіатрична платформа</title>
<style>body{{font-family:Arial,sans-serif;margin:2rem;color:#18324A}}table{{border-collapse:collapse;width:100%}}th,td{{border:1px solid #CBD5E0;padding:.55rem;text-align:left}}th{{background:#EDF2F7}}code{{font-size:.9rem}}</style></head>
<body><h1>Попередній статичний перегляд C4-діаграм</h1>
<p>Авторитетним джерелом є <code>workspace.dsl</code>. Ці файли сформовано Graphviz для швидкого локального перегляду без Structurizr.</p>
<table><thead><tr><th>Ключ</th><th>Назва</th><th>Тип</th><th>SVG</th><th>PNG</th></tr></thead><tbody>{''.join(rows)}</tbody></table>
</body></html>'''
    (out_root / "index.html").write_text(page, encoding="utf-8")


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("workspace", type=Path)
    ap.add_argument("output", type=Path)
    args = ap.parse_args()
    lines = args.workspace.read_text(encoding="utf-8").splitlines()
    m_start, m_end = find_block(lines, r'^\s*model\s*\{')
    v_start, v_end = find_block(lines, r'^\s*views\s*\{')
    elements, short_to_full = parse_elements(lines, m_start, m_end)
    relationships = parse_relationships(lines, m_start, m_end, elements, short_to_full)
    views = parse_views(lines, v_start, v_end, elements, short_to_full)
    out = args.output
    (out / "svg").mkdir(parents=True, exist_ok=True)
    (out / "png").mkdir(parents=True, exist_ok=True)
    (out / "dot").mkdir(parents=True, exist_ok=True)
    for view in views:
        dot_path = out / "dot" / f"{view.key}.dot"
        svg_path = out / "svg" / f"{view.key}.svg"
        png_path = out / "png" / f"{view.key}.png"
        if view.key in SLIDE_VIEW_KEYS:
            render_slide(view, elements, dot_path, svg_path, png_path)
            continue
        if view.kind == "dynamic":
            text = dynamic_dot(view, elements)
        elif view.kind == "deployment":
            text = deployment_dot(view, elements, relationships)
        else:
            text = static_dot(view, elements, relationships)
        render(text, dot_path, svg_path, png_path)
    build_index(views, out)
    print(f"Rendered {len(views)} previews to {out}")


if __name__ == "__main__":
    main()
