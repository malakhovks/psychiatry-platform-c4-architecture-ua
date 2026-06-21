#!/usr/bin/env node
'use strict';

const path = require('path');
const pptxgen = require('pptxgenjs');

const root = path.resolve(__dirname, '..');
const output = process.argv[2]
  ? path.resolve(process.argv[2])
  : path.join(root, 'C1_updated_slide_diagrams_UA.pptx');

const pptx = new pptxgen();
pptx.layout = 'LAYOUT_WIDE';
pptx.author = 'Архітектурна команда проєкту';
pptx.company = 'TNMU';
pptx.subject = 'C1-діаграми програмної платформи психіатричних сценаріїв та алгоритмів';
pptx.title = 'Оновлені C1-діаграми платформи психіатричних сценаріїв';
pptx.lang = 'uk-UA';
pptx.theme = {
  headFontFace: 'Noto Sans',
  bodyFontFace: 'Noto Sans',
  lang: 'uk-UA',
};
pptx.margin = 0;

const slideWidth = 13.333333;
const slideHeight = 7.5;
const diagrams = [
  ['C1-01-Landscape', 'C1.01 — Ландшафт системи психіатричних сценаріїв'],
  ['C1-03-PatientContext', 'C1.03 — Контекст ШІ-асистента пацієнта'],
  ['C1-04-ClinicianContext', 'C1.04 — Контекст ШІ-асистента медичного працівника'],
];

for (const [key, title] of diagrams) {
  const slide = pptx.addSlide();
  slide.background = { color: 'FFFFFF' };
  slide.addImage({
    path: path.join(root, 'previews', 'png', `${key}.png`),
    x: 0,
    y: 0,
    w: slideWidth,
    h: slideHeight,
    altText: title,
  });
  slide.addNotes(
    `Оновлена презентаційна діаграма ${title}. ` +
    'Усі текстові написи перевірено та розміщено всередині відповідних фігур або текстових областей.'
  );
}

pptx.writeFile({ fileName: output });
