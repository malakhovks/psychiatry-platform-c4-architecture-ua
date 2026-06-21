from __future__ import annotations
import argparse
import html
import subprocess
from pathlib import Path
from typing import List, Tuple

import cairosvg
from PIL import ImageFont

ROOT = Path(__file__).resolve().parents[1]
W, H = 1920, 1080
FONT_FAMILY = "'Noto Sans', 'DejaVu Sans', Arial, sans-serif"
FONT_REG = '/usr/share/fonts/truetype/noto/NotoSans-Regular.ttf'
FONT_BOLD = '/usr/share/fonts/truetype/noto/NotoSans-Bold.ttf'

COLORS = {
    'bg': '#FFFFFF',
    'title': '#17324D',
    'subtitle': '#486581',
    'line': '#486581',
    'panel_fill': '#F8FBFE',
    'panel_stroke': '#AFC5D6',
    'panel_header': '#E9F2FA',
    'panel_header_text': '#1F3B53',
    'system': '#0A6EBD',
    'system_stroke': '#075A9A',
    'patient': '#0C7C8C',
    'psy': '#6C4AB6',
    'specialist': '#2F73B8',
    'ops': '#4A5568',
    'external': '#E9EEF4',
    'external_text': '#263238',
    'crisis': '#D92323',
    'ai': '#6741D9',
    'note': '#486581',
}

VERIFY = []


def font(size: int, bold: bool = False) -> ImageFont.FreeTypeFont:
    return ImageFont.truetype(FONT_BOLD if bold else FONT_REG, size=size)


def measure(text: str, size: int, bold: bool = False) -> Tuple[float, float]:
    f = font(size, bold)
    if text == '':
        return 0, size
    bbox = f.getbbox(text)
    return bbox[2] - bbox[0], bbox[3] - bbox[1]


def wrap_para(words: List[str], max_w: float, size: int, bold: bool) -> List[str]:
    lines: List[str] = []
    line = ''
    for word in words:
        candidate = word if not line else line + ' ' + word
        if measure(candidate, size, bold)[0] <= max_w:
            line = candidate
        else:
            if line:
                lines.append(line)
                line = word
            else:
                # Very rare; split long token conservatively.
                token = word
                part = ''
                for ch in token:
                    cand = part + ch
                    if measure(cand, size, bold)[0] <= max_w:
                        part = cand
                    else:
                        if part:
                            lines.append(part)
                        part = ch
                line = part
    if line:
        lines.append(line)
    return lines


def wrap_text(text: str, max_w: float, size: int, bold: bool) -> List[str]:
    all_lines: List[str] = []
    for para in text.split('\n'):
        words = para.split()
        if not words:
            all_lines.append('')
        else:
            all_lines.extend(wrap_para(words, max_w, size, bold))
    return all_lines


def fit_lines(text: str, max_w: float, max_h: float, size: int, bold: bool, min_size: int = 10, line_factor: float = 1.16, max_lines: int | None = None) -> Tuple[List[str], int, float]:
    for s in range(size, min_size - 1, -1):
        lines = wrap_text(text, max_w, s, bold)
        line_h = s * line_factor
        total_h = len(lines) * line_h
        widths_ok = all(measure(l, s, bold)[0] <= max_w + 0.5 for l in lines)
        lines_ok = max_lines is None or len(lines) <= max_lines
        if widths_ok and total_h <= max_h and lines_ok:
            return lines, s, line_h
    # Last resort: keep fitting by width, allow smaller text.
    s = min_size
    lines = wrap_text(text, max_w, s, bold)
    return lines, s, s * line_factor


def attrs(**kw) -> str:
    parts = []
    for k, v in kw.items():
        if v is None:
            continue
        k = k.replace('_', '-')
        parts.append(f'{k}="{html.escape(str(v), quote=True)}"')
    return ' '.join(parts)


class Svg:
    def __init__(self):
        self.parts: List[str] = []
        self.parts.append(f'<svg xmlns="http://www.w3.org/2000/svg" width="{W}" height="{H}" viewBox="0 0 {W} {H}">')
        self.parts.append('''<defs>
  <marker id="arrow" markerWidth="18" markerHeight="18" refX="16" refY="9" orient="auto" markerUnits="userSpaceOnUse"><path d="M0,0 L18,9 L0,18 z" fill="#486581"/></marker>
  <filter id="softShadow" x="-10%" y="-10%" width="120%" height="120%"><feDropShadow dx="0" dy="1.2" stdDeviation="1.2" flood-color="#8AA2B4" flood-opacity="0.22"/></filter>
</defs>''')
        self.rect(0,0,W,H, fill=COLORS['bg'])

    def rect(self, x, y, w, h, rx=0, fill='none', stroke=None, stroke_width=1, filter=None):
        self.parts.append(f'<rect {attrs(x=x, y=y, width=w, height=h, rx=rx, fill=fill, stroke=stroke, **{"stroke_width": stroke_width} if stroke else {}, filter=filter)}/>')

    def line(self, x1, y1, x2, y2, stroke=COLORS['line'], sw=3.2, arrow=True):
        marker = 'url(#arrow)' if arrow else None
        self.parts.append(f'<line {attrs(x1=x1, y1=y1, x2=x2, y2=y2, fill="none", stroke=stroke, **{"stroke_width": sw}, **{"stroke_linecap": "round", "stroke_linejoin": "round"}, **({"marker_end": marker} if marker else {}))}/>')

    def polyline(self, points: List[Tuple[float,float]], stroke=COLORS['line'], sw=3.2, arrow=True):
        pts = ' '.join(f'{x},{y}' for x,y in points)
        marker = 'url(#arrow)' if arrow else None
        self.parts.append(f'<polyline {attrs(points=pts, fill="none", stroke=stroke, **{"stroke_width": sw}, **{"stroke_linecap": "round", "stroke_linejoin": "round"}, **({"marker_end": marker} if marker else {}))}/>')

    def text_box(self, x, y, w, h, text, size=20, bold=False, fill='#263238', align='center', valign='middle', padding=8, line_factor=1.16, max_lines=None, min_size=10):
        max_w = max(1, w - 2*padding)
        max_h = max(1, h - 2*padding)
        lines, fitted_size, line_h = fit_lines(text, max_w, max_h, size, bold, min_size, line_factor, max_lines)
        total_h = len(lines) * line_h
        if valign == 'middle':
            y0 = y + (h - total_h)/2 + fitted_size*0.82
        elif valign == 'top':
            y0 = y + padding + fitted_size*0.82
        else:
            y0 = y + h - padding - total_h + fitted_size*0.82
        if align == 'center':
            tx = x + w/2
            anchor = 'middle'
        elif align == 'left':
            tx = x + padding
            anchor = 'start'
        else:
            tx = x + w - padding
            anchor = 'end'
        VERIFY.append((text, x, y, w, h, lines, fitted_size, bold, padding))
        self.parts.append(f'<text {attrs(x=tx, y=round(y0,1), text_anchor=anchor, font_family=FONT_FAMILY, font_size=fitted_size, font_weight=(700 if bold else 400), fill=fill)}>')
        for i, line in enumerate(lines):
            dy = 0 if i == 0 else round(line_h, 1)
            self.parts.append(f'<tspan {attrs(x=tx, dy=dy)}>{html.escape(line)}</tspan>')
        self.parts.append('</text>')

    def title(self, main: str, subtitle: str):
        self.text_box(100, 68, 1720, 54, main, size=42, bold=True, fill=COLORS['title'], padding=0, min_size=30)
        self.text_box(130, 122, 1660, 34, subtitle, size=22, bold=False, fill=COLORS['subtitle'], padding=0, min_size=17)

    def panel(self, x, y, w, h, title, header_h=54, title_size=27):
        self.rect(x,y,w,h, rx=13, fill=COLORS['panel_fill'], stroke=COLORS['panel_stroke'], stroke_width=2.4, filter='url(#softShadow)')
        self.rect(x,y,w,header_h, rx=13, fill=COLORS['panel_header'], stroke=None)
        # mask lower radius of header with a straight light rectangle
        self.rect(x, y+header_h-8, w, 8, rx=0, fill=COLORS['panel_header'], stroke=None)
        self.line(x+2, y+header_h, x+w-2, y+header_h, stroke='#C4D6E4', sw=1.2, arrow=False)
        self.text_box(x+14, y+6, w-28, header_h-12, title, size=title_size, bold=True, fill=COLORS['panel_header_text'], align='left', padding=0, line_factor=1.07, min_size=18)

    def node(self, x, y, w, h, text, fill, stroke=None, size=22, role=None, text_color='#FFFFFF', rx=10, title_min=14):
        self.rect(x,y,w,h, rx=rx, fill=fill, stroke=(stroke or COLORS['line']), stroke_width=2.2)
        if role:
            self.text_box(x+8,y+6,w-16,h-28,text, size=size, bold=True, fill=text_color, padding=4, line_factor=1.05, min_size=title_min)
            self.text_box(x+8,y+h-29,w-16,22,role, size=14, bold=False, fill=text_color, padding=2, line_factor=1.0, min_size=10)
        else:
            self.text_box(x+8,y+6,w-16,h-12,text, size=size, bold=True, fill=text_color, padding=4, line_factor=1.05, min_size=title_min)

    def finish(self) -> str:
        self.parts.append('</svg>')
        return ''.join(self.parts)


def add_central_platform(svg: Svg, x, y, w, h):
    svg.rect(x,y,w,h, rx=15, fill=COLORS['system'], stroke=COLORS['system_stroke'], stroke_width=3, filter='url(#softShadow)')
    svg.text_box(x+18, y+18, w-36, h-55, 'Платформа реалізації\nпсихіатричних сценаріїв\nта алгоритмів', size=28, bold=True, fill='#FFFFFF', padding=2, line_factor=1.05, min_size=21)
    svg.text_box(x+20, y+h-38, w-40, 24, '[Програмна система]', size=17, fill='#FFFFFF', padding=0, min_size=14)


def render_c101() -> str:
    svg = Svg()
    svg.title('C1.01 — Ландшафт системи психіатричних сценаріїв', 'Користувачі, клінічні спеціалісти та зовнішні системи, інтегровані з платформою')

    # left panels
    lx, lw = 145, 500
    svg.panel(lx, 185, lw, 250, 'Користувачі та основний\nклінічний контур', header_h=66, title_size=25)
    bx, by = lx+30, 273
    bw, bh = 205, 62
    gapx, gapy = 30, 22
    svg.node(bx, by, bw, bh, 'Пацієнт', COLORS['patient'], size=26)
    svg.node(bx+bw+gapx, by, bw, bh, 'Лікар-психіатр', COLORS['psy'], size=22)
    svg.node(bx, by+bh+gapy, bw, bh, 'Психолог /\nпсихотерапевт', COLORS['psy'], size=20)
    svg.node(bx+bw+gapx, by+bh+gapy, bw, bh, 'Медична сестра /\nкоординатор', COLORS['psy'], size=18)

    svg.panel(lx, 460, lw, 250, 'Суміжні медичні спеціалісти', header_h=54, title_size=25)
    by = 536
    svg.node(bx, by, bw, bh, 'Кардіолог', COLORS['specialist'], '#1F5E9C', size=25)
    svg.node(bx+bw+gapx, by, bw, bh, 'Реабілітолог', COLORS['specialist'], '#1F5E9C', size=24)
    svg.node(bx, by+bh+gapy, bw, bh, 'Невролог', COLORS['specialist'], '#1F5E9C', size=25)
    svg.node(bx+bw+gapx, by+bh+gapy, bw, bh, 'Педіатр', COLORS['specialist'], '#1F5E9C', size=25)

    svg.panel(lx, 735, lw, 170, 'Дослідження й експлуатація', header_h=54, title_size=25)
    by = 820
    svg.node(bx, by, bw, 64, 'Аналітик /\nдослідник', COLORS['patient'], size=19)
    svg.node(bx+bw+gapx, by, bw, 64, 'Адміністратор\nплатформи\nта безпеки', COLORS['ops'], size=17)

    # central
    cx, cy, cw, ch = 770, 438, 380, 150
    add_central_platform(svg, cx, cy, cw, ch)

    # right panels
    rx, rw = 1275, 500
    svg.panel(rx, 185, rw, 265, 'Клінічні дані та знання', header_h=54, title_size=25)
    rbw, rbh = 206, 48
    rbx, rby = rx+28, 255
    rgx, rgy = 32, 14
    svg.node(rbx, rby, rbw, rbh, 'МІС / EHR / ЕСОЗ', COLORS['external'], text_color=COLORS['external_text'], size=17, title_min=13)
    svg.node(rbx+rbw+rgx, rby, rbw, rbh, 'Сервіс\nтермінологій', COLORS['external'], text_color=COLORS['external_text'], size=16, title_min=12)
    svg.node(rbx, rby+rbh+rgy, rbw, rbh, 'Клінічні\nпротоколи', COLORS['external'], text_color=COLORS['external_text'], size=16, title_min=12)
    svg.node(rbx+rbw+rgx, rby+rbh+rgy, rbw, rbh, 'Репозиторій\nвихідних алгоритмів', COLORS['external'], text_color=COLORS['external_text'], size=14, title_min=11)
    svg.node(rbx, rby+2*(rbh+rgy), rw-56, rbh, 'PACS / DICOM-сховище', COLORS['external'], text_color=COLORS['external_text'], size=17, title_min=13)

    svg.panel(rx, 475, rw, 220, 'Комунікація та маршрутизація', header_h=54, title_size=25)
    rby = 545
    svg.node(rbx, rby, rbw, rbh, 'Провайдер\nповідомлень', COLORS['external'], text_color=COLORS['external_text'], size=16, title_min=12)
    svg.node(rbx+rbw+rgx, rby, rbw, rbh, 'Календар і запис\nна прийом', COLORS['external'], text_color=COLORS['external_text'], size=15, title_min=12)
    svg.node(rbx, rby+rbh+rgy, rbw, rbh, 'Платформа\nтелемедицини', COLORS['external'], text_color=COLORS['external_text'], size=16, title_min=12)
    svg.node(rbx+rbw+rgx, rby+rbh+rgy, rbw, rbh, 'Кризова / екстрена\nслужба', COLORS['crisis'], '#A91515', size=15, title_min=12)

    svg.panel(rx, 720, rw, 180, 'Ідентичність, вимірювання та ШІ', header_h=54, title_size=23)
    rby = 800
    small_w = 142
    small_gap = 11
    svg.node(rx+24, rby, small_w, 58, 'Електронна\nідентичність', COLORS['external'], text_color=COLORS['external_text'], size=14, title_min=11)
    svg.node(rx+24+small_w+small_gap, rby, small_w, 58, 'Медичні\nпристрої та\nсенсори', COLORS['external'], text_color=COLORS['external_text'], size=13, title_min=10)
    svg.node(rx+24+2*(small_w+small_gap), rby, small_w, 58, 'Моделі\nШІ', COLORS['ai'], text_color='#FFFFFF', size=17, title_min=12)

    # arrows behind labels but after panels; no crossing text blocks
    svg.polyline([(lx+lw, 310), (700, 310), (cx, 462)], sw=3.2)
    svg.polyline([(lx+lw, 585), (714, 585), (cx, 520)], sw=3.2)
    svg.polyline([(lx+lw, 820), (710, 820), (cx, 574)], sw=3.2)
    svg.polyline([(cx+cw, 462), (1210, 462), (rx, 315)], sw=3.2)
    svg.polyline([(cx+cw, 520), (1212, 520), (rx, 585)], sw=3.2)
    svg.polyline([(cx+cw, 574), (1210, 574), (rx, 810)], sw=3.2)

    svg.text_box(240, 957, 1440, 36, 'Сині модулі — кардіолог, реабілітолог, невролог і педіатр; клінічні рішення залишаються за уповноваженим фахівцем.', size=18, fill=COLORS['note'], padding=0, min_size=15)
    return svg.finish()


def render_c103() -> str:
    svg = Svg()
    svg.title('C1.03 — Контекст ШІ-асистента пацієнта', 'Компактна взаємодія пацієнта і лікаря: скринінг, вимірювання, консультація, супровід і кризова маршрутизація')
    # Left compact participants
    lx, ly, lw, lh = 220, 325, 390, 330
    svg.panel(lx, ly, lw, lh, 'Учасники взаємодії', header_h=58, title_size=25)
    svg.node(lx+44, ly+96, lw-88, 80, 'Пацієнт', COLORS['patient'], size=31, role='[Особа]')
    svg.node(lx+44, ly+210, lw-88, 80, 'Лікар-психіатр', COLORS['psy'], size=27, role='[Особа]')

    # Central platform
    cx, cy, cw, ch = 735, 405, 450, 170
    add_central_platform(svg, cx, cy, cw, ch)
    svg.text_box(cx, cy+178, cw, 32, 'Детерміновані сценарії + контрольований ШІ', size=18, fill=COLORS['subtitle'], padding=0, min_size=14)

    # Right services panel
    rx, ry, rw, rh = 1290, 250, 450, 550
    svg.panel(rx, ry, rw, rh, 'Зовнішні сервіси', header_h=60, title_size=26)
    sbx, sby, sw, sh, sg = rx+40, ry+90, rw-80, 68, 25
    svg.node(sbx, sby, sw, sh, 'Календар і запис\nна прийом', COLORS['external'], text_color=COLORS['external_text'], size=19, title_min=14)
    svg.node(sbx, sby+(sh+sg), sw, sh, 'Медичні пристрої\nта сенсори', COLORS['external'], text_color=COLORS['external_text'], size=19, title_min=14)
    svg.node(sbx, sby+2*(sh+sg), sw, sh, 'Кризова / екстрена\nслужба', COLORS['crisis'], '#A91515', size=20, title_min=15)
    svg.node(sbx, sby+3*(sh+sg), sw, sh, 'Провайдер\nповідомлень', COLORS['external'], text_color=COLORS['external_text'], size=20, title_min=14)
    svg.node(sbx, sby+4*(sh+sg), sw, sh, 'Платформа\nтелемедицини', COLORS['external'], text_color=COLORS['external_text'], size=20, title_min=14)

    # arrows
    svg.line(lx+lw, ly+136, cx, cy+60, sw=3.2)
    svg.line(lx+lw, ly+250, cx, cy+112, sw=3.2)
    service_y = [sby+sh/2, sby+(sh+sg)+sh/2, sby+2*(sh+sg)+sh/2, sby+3*(sh+sg)+sh/2, sby+4*(sh+sg)+sh/2]
    exit_points = [(cx+cw, cy+48), (cx+cw, cy+76), (cx+cw, cy+104), (cx+cw, cy+132), (cx+cw, cy+154)]
    for (x0,y0), ysvc in zip(exit_points, service_y):
        svg.polyline([(x0, y0), (1245, y0), (sbx, ysvc)], sw=3.1)
    svg.text_box(245, 960, 1430, 36, 'ШІ-асистент підтримує комунікацію та маршрутизацію, але не замінює лікаря і не змінює клінічні правила.', size=18, fill=COLORS['note'], padding=0, min_size=15)
    return svg.finish()


def render_c104() -> str:
    svg = Svg()
    svg.title('C1.04 — Контекст ШІ-асистента медичного працівника', 'Клінічні ролі та основні системи для оцінювання ризиків, мультимодального аналізу й ведення траєкторії пацієнта')
    lx, lw = 150, 520
    svg.panel(lx, 200, lw, 275, 'Психіатричний та\nкризовий контур', header_h=72, title_size=25)
    bx, by = lx+32, 292
    bw, bh = 215, 70
    gapx, gapy = 26, 24
    svg.node(bx, by, bw, bh, 'Лікар-психіатр', COLORS['psy'], size=24)
    svg.node(bx+bw+gapx, by, bw, bh, 'Психолог /\nпсихотерапевт', COLORS['psy'], size=19)
    svg.node(bx, by+bh+gapy, bw, bh, 'Медична сестра /\nкоординатор', COLORS['psy'], size=17)
    svg.node(bx+bw+gapx, by+bh+gapy, bw, bh, 'Черговий кризовий\nфахівець', COLORS['psy'], size=17)

    svg.panel(lx, 505, lw, 265, 'Суміжні медичні спеціалісти', header_h=56, title_size=25)
    by = 585
    svg.node(bx, by, bw, bh, 'Кардіолог', COLORS['specialist'], '#1F5E9C', size=25)
    svg.node(bx+bw+gapx, by, bw, bh, 'Реабілітолог', COLORS['specialist'], '#1F5E9C', size=24)
    svg.node(bx, by+bh+gapy, bw, bh, 'Невролог', COLORS['specialist'], '#1F5E9C', size=25)
    svg.node(bx+bw+gapx, by+bh+gapy, bw, bh, 'Педіатр', COLORS['specialist'], '#1F5E9C', size=25)

    cx, cy, cw, ch = 760, 430, 400, 165
    add_central_platform(svg, cx, cy, cw, ch)

    rx, rw = 1275, 510
    svg.panel(rx, 200, rw, 275, 'Клінічні дані та вимірювання', header_h=56, title_size=25)
    rbw, rbh = 213, 70
    rbx, rby = rx+34, 282
    rgx, rgy = 28, 28
    svg.node(rbx, rby, rbw, rbh, 'МІС / EHR / ЕСОЗ', COLORS['external'], text_color=COLORS['external_text'], size=19, title_min=14)
    svg.node(rbx+rbw+rgx, rby, rbw, rbh, 'Медичні пристрої\nта сенсори', COLORS['external'], text_color=COLORS['external_text'], size=17, title_min=13)
    svg.node(rbx, rby+rbh+rgy, rbw, rbh, 'PACS / DICOM-\nсховище', COLORS['external'], text_color=COLORS['external_text'], size=18, title_min=13)
    svg.node(rbx+rbw+rgx, rby+rbh+rgy, rbw, rbh, 'Реєстр і\nсередовище\nмоделей ШІ', COLORS['ai'], text_color='#FFFFFF', size=16, title_min=12)

    svg.panel(rx, 505, rw, 265, 'Знання, взаємодія та безпека', header_h=56, title_size=25)
    rby = 585
    svg.node(rbx, rby, rbw, rbh, 'Клінічні протоколи\nі знання', COLORS['external'], text_color=COLORS['external_text'], size=16, title_min=12)
    svg.node(rbx+rbw+rgx, rby, rbw, rbh, 'Сервіс\nтермінологій', COLORS['external'], text_color=COLORS['external_text'], size=17, title_min=12)
    svg.node(rbx, rby+rbh+rgy, rbw, rbh, 'Платформа\nтелемедицини', COLORS['external'], text_color=COLORS['external_text'], size=18, title_min=13)
    svg.node(rbx+rbw+rgx, rby+rbh+rgy, rbw, rbh, 'Кризова / екстрена\nслужба', COLORS['crisis'], '#A91515', size=17, title_min=13)

    # arrows with elbow routing
    svg.polyline([(lx+lw, 330), (715, 330), (cx, 472)], sw=3.2)
    svg.polyline([(lx+lw, 625), (715, 625), (cx, 560)], sw=3.2)
    svg.polyline([(cx+cw, 472), (1225, 472), (rx, 330)], sw=3.2)
    svg.polyline([(cx+cw, 560), (1225, 560), (rx, 625)], sw=3.2)
    svg.text_box(220, 958, 1480, 36, 'Сині модулі — кардіолог, реабілітолог, невролог і педіатр; усі клінічно значущі висновки підлягають людському контролю.', size=18, fill=COLORS['note'], padding=0, min_size=15)
    return svg.finish()


def verify_textboxes() -> List[str]:
    errors = []
    for text, x, y, w, h, lines, size, bold, padding in VERIFY:
        max_w = w - 2*padding
        line_h = size * 1.18  # conservative
        if len(lines) * line_h > h - 2*padding + 6:
            errors.append(f'HEIGHT: {text!r} in {w}x{h}, lines={lines}, size={size}')
        for line in lines:
            if measure(line, size, bold)[0] > max_w + 3:
                errors.append(f'WIDTH: {line!r} for {text!r}: {measure(line,size,bold)[0]:.1f}>{max_w:.1f}, size={size}')
    return errors


def render_view(key: str) -> tuple[str, int]:
    """Render one presentation-specific C1 view and validate every text area."""
    renderers = {
        "C1-01-Landscape": render_c101,
        "C1-03-PatientContext": render_c103,
        "C1-04-ClinicianContext": render_c104,
    }
    if key not in renderers:
        raise KeyError(f"Непідтримуваний ключ слайдової C1-діаграми: {key}")
    VERIFY.clear()
    svg_text = renderers[key]()
    errors = verify_textboxes()
    if errors:
        raise RuntimeError("Перевірка розміщення тексту не пройдена:\n" + "\n".join(errors[:20]))
    return svg_text, len(VERIFY)


def save_svg_png(output_dir: Path, key: str, svg_text: str) -> tuple[Path, Path]:
    svg_dir = output_dir / "svg"
    png_dir = output_dir / "png"
    svg_dir.mkdir(parents=True, exist_ok=True)
    png_dir.mkdir(parents=True, exist_ok=True)
    svg_path = svg_dir / f"{key}.svg"
    png_path = png_dir / f"{key}.png"
    svg_path.write_text(svg_text, encoding="utf-8")
    if cairosvg is not None:
        cairosvg.svg2png(
            bytestring=svg_text.encode("utf-8"),
            write_to=str(png_path),
            output_width=W,
            output_height=H,
        )
    else:
        subprocess.run(
            [
                "inkscape",
                str(svg_path),
                "--export-type=png",
                f"--export-filename={png_path}",
                f"--export-width={W}",
                f"--export-height={H}",
            ],
            check=True,
        )
    return svg_path, png_path


def main() -> None:
    parser = argparse.ArgumentParser(
        description="Створення та перевірка презентаційних C1.01, C1.03 і C1.04."
    )
    parser.add_argument(
        "--output-dir",
        type=Path,
        default=ROOT / "previews",
        help="Каталог previews із підкаталогами svg/ і png/.",
    )
    parser.add_argument(
        "--report",
        type=Path,
        default=ROOT / "validation" / "c1-text-fit-validation.txt",
        help="Файл звіту автоматичної перевірки текстових блоків.",
    )
    parser.add_argument(
        "--only",
        action="append",
        choices=["C1-01-Landscape", "C1-03-PatientContext", "C1-04-ClinicianContext"],
        help="Створити лише вказане подання; параметр можна повторювати.",
    )
    args = parser.parse_args()

    keys = args.only or [
        "C1-01-Landscape",
        "C1-03-PatientContext",
        "C1-04-ClinicianContext",
    ]
    checked = 0
    for key in keys:
        svg_text, count = render_view(key)
        save_svg_png(args.output_dir, key, svg_text)
        checked += count

    args.report.parent.mkdir(parents=True, exist_ok=True)
    report_text = (
        f"OK: {checked} текстових блоків перевірено. "
        "Усі написи розміщено всередині призначених фігур або текстових областей.\n"
    )
    args.report.write_text(report_text, encoding="utf-8")
    print(report_text, end="")


if __name__ == "__main__":
    main()
