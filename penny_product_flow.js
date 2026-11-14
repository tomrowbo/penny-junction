const pptxgen = require('pptxgenjs');

const pptx = new pptxgen();
pptx.layout = 'LAYOUT_WIDE';
pptx.author = 'Penny';
pptx.subject = 'Receipt-enriched financial coaching product flow';
pptx.title = 'Penny — Product Flow';
pptx.company = 'Junction 2026';
pptx.lang = 'en-GB';
pptx.theme = {
  headFontFace: 'Arial',
  bodyFontFace: 'Arial',
  lang: 'en-GB'
};
pptx.defineSlideMaster({
  title: 'LIGHT',
  background: { color: 'F7F9F7' },
  objects: []
});
pptx.defineSlideMaster({
  title: 'DARK',
  background: { color: '123A2A' },
  objects: []
});

const C = {
  forest: '123A2A',
  green: '238653',
  green2: '2FA66A',
  mint: 'EAF5EE',
  pale: 'F7F9F7',
  white: 'FFFFFF',
  ink: '14231B',
  muted: '69766F',
  line: 'D6DED9',
  bubble: 'E9E9EB',
  blue: '0A84FF',
  snack: 'F4C95D',
  red: 'C95656'
};

function text(slide, value, x, y, w, h, opts = {}) {
  slide.addText(value, {
    x, y, w, h,
    fontFace: opts.fontFace || 'Arial',
    fontSize: opts.fontSize || 16,
    color: opts.color || C.ink,
    bold: !!opts.bold,
    italic: !!opts.italic,
    align: opts.align || 'left',
    valign: opts.valign || 'mid',
    margin: opts.margin === undefined ? 0 : opts.margin,
    breakLine: false,
    fit: opts.fit || 'shrink',
    isTextBox: true,
    ...opts
  });
}

function roundRect(slide, x, y, w, h, fill, radius = 0.14, line = null, shadow = null) {
  slide.addShape(pptx.ShapeType.roundRect, {
    x, y, w, h,
    rectRadius: radius,
    fill: { color: fill },
    line: line ? { color: line, width: 1 } : { color: fill, transparency: 100 },
    shadow: shadow || undefined
  });
}

function circle(slide, x, y, d, fill, label, labelColor = C.white, fontSize = 18) {
  slide.addShape(pptx.ShapeType.ellipse, {
    x, y, w: d, h: d,
    fill: { color: fill },
    line: { color: fill, transparency: 100 }
  });
  text(slide, label, x, y, d, d, { color: labelColor, bold: true, fontSize, align: 'center' });
}

function arrow(slide, x1, y1, x2, y2, color = C.green) {
  slide.addShape(pptx.ShapeType.line, {
    x: x1, y: y1, w: x2 - x1, h: y2 - y1,
    line: { color, width: 2.2, beginArrowType: 'none', endArrowType: 'triangle' }
  });
}

function tag(slide, label, dark = false) {
  roundRect(slide, 0.55, 0.38, 2.25, 0.34, dark ? '24513F' : C.mint, 0.14);
  text(slide, label, 0.72, 0.4, 1.94, 0.27, {
    color: dark ? 'BCE0CB' : C.green,
    bold: true,
    fontSize: 10,
    charSpacing: 1.4
  });
}

function phoneShell(slide, x, y, w, h, title = 'Penny') {
  roundRect(slide, x, y, w, h, C.white, 0.25, 'D5DAD7', {
    type: 'outer', color: '000000', opacity: 0.14, blur: 2, angle: 45, distance: 2
  });
  text(slide, '9:41', x + 0.28, y + 0.16, 0.55, 0.24, { fontSize: 10, bold: true });
  roundRect(slide, x + w / 2 - 0.38, y + 0.13, 0.76, 0.22, '000000', 0.12);
  text(slide, '▮▮  WiFi  ▰', x + w - 1.18, y + 0.15, 0.92, 0.24, { fontSize: 8.5, bold: true, align: 'right' });
  slide.addShape(pptx.ShapeType.line, { x, y: y + 0.56, w, h: 0, line: { color: 'E4E7E5', width: 1 } });
  circle(slide, x + w / 2 - 0.22, y + 0.47, 0.44, C.green, '£', C.white, 17);
  text(slide, title, x + 0.45, y + 0.9, w - 0.9, 0.25, { fontSize: 11, bold: true, align: 'center' });
  text(slide, '‹ 12', x + 0.22, y + 0.83, 0.6, 0.25, { color: C.blue, fontSize: 11 });
  slide.addShape(pptx.ShapeType.line, { x, y: y + 1.25, w, h: 0, line: { color: 'E4E7E5', width: 1 } });
  return { x, y, w, h, contentY: y + 1.36 };
}

function bubble(slide, value, x, y, w, h, mine = false, fontSize = 12) {
  roundRect(slide, x, y, w, h, mine ? C.blue : C.bubble, 0.16);
  text(slide, value, x + 0.14, y + 0.07, w - 0.28, h - 0.14, {
    fontSize,
    color: mine ? C.white : '151515',
    valign: 'mid'
  });
}

function composer(slide, phone) {
  const y = phone.y + phone.h - 0.56;
  circle(slide, phone.x + 0.18, y + 0.08, 0.3, 'F0F1F2', '+', C.muted, 16);
  roundRect(slide, phone.x + 0.55, y, phone.w - 0.75, 0.42, C.white, 0.19, 'C8CECA');
  text(slide, 'iMessage', phone.x + 0.72, y + 0.08, phone.w - 1.25, 0.23, { color: '8C9490', fontSize: 10 });
  text(slide, '◉', phone.x + phone.w - 0.52, y + 0.08, 0.2, 0.22, { color: C.muted, fontSize: 10, align: 'center' });
}

// Slide 1 — data gap
{
  const s = pptx.addSlide('DARK');
  tag(s, '01  THE DATA GAP', true);
  text(s, 'The bank sees £46.80.\nPenny sees the habit.', 0.65, 1.05, 5.2, 1.45, {
    color: C.white, fontSize: 31, bold: true, breakLine: false, valign: 'top', fit: 'shrink'
  });
  text(s, 'Transactions identify the merchant. Receipts reveal the individual choices that actually shape a budget.', 0.68, 2.72, 4.85, 0.78, {
    color: 'C9D9D0', fontSize: 16, valign: 'top'
  });
  roundRect(s, 0.68, 4.0, 4.7, 1.25, '1D4A38', 0.16);
  circle(s, 0.95, 4.28, 0.58, 'EAF5EE', 'T', C.green, 19);
  text(s, 'TESCO', 1.72, 4.17, 1.2, 0.28, { color: C.white, bold: true, fontSize: 15 });
  text(s, 'Yesterday · Card transaction', 1.72, 4.52, 2.3, 0.25, { color: 'B8CFC2', fontSize: 10.5 });
  text(s, '£46.80', 4.05, 4.26, 0.95, 0.4, { color: C.white, bold: true, fontSize: 20, align: 'right' });
  text(s, 'What changed?', 0.68, 5.63, 1.5, 0.3, { color: '9BC2AC', bold: true, fontSize: 11, charSpacing: 1.2 });
  text(s, 'The transaction cannot tell us.', 0.68, 5.97, 3.5, 0.42, { color: C.white, fontSize: 18, bold: true });

  roundRect(s, 6.18, 0.66, 6.48, 6.22, C.white, 0.2, null, {
    type: 'outer', color: '000000', opacity: 0.18, blur: 2, angle: 45, distance: 2
  });
  text(s, 'ITEMISED RECEIPT', 6.62, 1.06, 2.1, 0.25, { color: C.green, bold: true, fontSize: 10, charSpacing: 1.5 });
  text(s, 'Tesco · 14 items', 6.62, 1.45, 2.7, 0.45, { color: C.ink, fontSize: 22, bold: true });
  text(s, 'Matched to £46.80 · 98% confidence', 9.55, 1.52, 2.45, 0.3, { color: C.muted, fontSize: 10.5, align: 'right' });
  const items = [
    ['Essential groceries', '£21.00', C.mint, C.green],
    ['Prepared meals', '£12.60', 'EEF1EF', C.ink],
    ['Snacks', '£12.40', 'FFF4CF', '8A6200'],
    ['Household', '£0.80', 'EEF1EF', C.ink]
  ];
  items.forEach((it, i) => {
    const yy = 2.15 + i * 0.72;
    roundRect(s, 6.58, yy, 5.66, 0.52, it[2], 0.12);
    circle(s, 6.76, yy + 0.12, 0.28, i === 2 ? C.snack : C.green, i === 2 ? '!' : '✓', i === 2 ? '5E4600' : C.white, 10);
    text(s, it[0], 7.2, yy + 0.09, 2.6, 0.3, { fontSize: 13, bold: i === 2, color: it[3] });
    text(s, it[1], 10.8, yy + 0.09, 1.08, 0.3, { fontSize: 13, bold: true, align: 'right', color: it[3] });
  });
  roundRect(s, 6.58, 5.25, 5.66, 1.05, C.mint, 0.14);
  text(s, 'PENNY INSIGHT', 6.85, 5.45, 1.55, 0.24, { color: C.green, fontSize: 9.5, bold: true, charSpacing: 1.2 });
  text(s, 'Snacks are £31 above your usual monthly pace.', 6.85, 5.76, 4.85, 0.32, { color: C.ink, fontSize: 15.5, bold: true });
  text(s, 'Bank data tells us where. Receipt data tells us what.', 6.58, 6.53, 5.7, 0.26, { color: C.muted, fontSize: 10.5, italic: true, align: 'center' });
  s.addNotes('Concept slide: establish why transaction feeds alone cannot support item-level coaching.');
}

// Slide 2 — multimodal data-fusion diagram
{
  const s = pptx.addSlide('LIGHT');
  tag(s, '02  THE PENNY MODEL', false);
  text(s, 'Three inputs. One continuously improving money model.', 0.62, 0.95, 9.3, 0.62, { fontSize: 30, bold: true, color: C.ink });
  text(s, 'Open banking provides the ledger. Receipts reveal the products. Penny turns both into advice people can act on.', 0.64, 1.62, 10.5, 0.42, { fontSize: 14.5, color: C.muted });

  text(s, 'INPUTS', 0.72, 2.32, 1.2, 0.25, { color: C.green, fontSize: 10, bold: true, charSpacing: 1.5 });
  const inputs = [
    { y: 2.67, icon: '£', title: 'Open banking', body: 'Balances, transactions, merchant,\ntotal and timestamp', fill: C.mint },
    { y: 3.94, icon: '@', title: 'Dedicated receipt email', body: 'E-receipts are forwarded; the user\nstill receives the original', fill: 'EDF3FF' },
    { y: 5.21, icon: '▣', title: 'Receipt photos', body: 'Paper receipts sent straight from\nthe iMessage conversation', fill: 'FFF4CF' }
  ];
  inputs.forEach((it) => {
    roundRect(s, 0.7, it.y, 3.18, 1.02, C.white, 0.16, C.line, {
      type: 'outer', color: '000000', opacity: 0.06, blur: 1.2, angle: 45, distance: 1
    });
    circle(s, 0.92, it.y + 0.21, 0.58, it.fill, it.icon, C.green, 17);
    text(s, it.title, 1.68, it.y + 0.17, 1.95, 0.27, { fontSize: 14, bold: true });
    text(s, it.body, 1.68, it.y + 0.49, 1.96, 0.38, { fontSize: 9.5, color: C.muted, valign: 'top' });
    arrow(s, 3.94, it.y + 0.51, 4.52, 4.51, '7DAF92');
  });

  roundRect(s, 4.55, 2.63, 4.15, 3.82, C.forest, 0.22, null, {
    type: 'outer', color: '000000', opacity: 0.15, blur: 2, angle: 45, distance: 2
  });
  circle(s, 6.26, 2.95, 0.72, C.green2, 'P', C.white, 24);
  text(s, 'Penny intelligence model', 5.05, 3.84, 3.15, 0.38, { color: C.white, fontSize: 20, bold: true, align: 'center' });
  const modelRows = [
    'Match receipt ↔ transaction',
    'Extract and classify every SKU',
    'Recalculate budgets and goals',
    'Learn from user corrections'
  ];
  modelRows.forEach((label, i) => {
    roundRect(s, 5.05, 4.4 + i * 0.43, 3.15, 0.32, '24513F', 0.12);
    circle(s, 5.2, 4.48 + i * 0.43, 0.16, 'BCE0CB', '✓', C.forest, 6.5);
    text(s, label, 5.51, 4.43 + i * 0.43, 2.5, 0.23, { color: 'EAF5EE', fontSize: 10.5, bold: i === 1 });
  });

  arrow(s, 8.82, 4.52, 9.42, 4.52, C.green);
  text(s, 'OUTPUT', 9.48, 2.32, 1.2, 0.25, { color: C.green, fontSize: 10, bold: true, charSpacing: 1.5 });
  roundRect(s, 9.42, 2.67, 3.2, 3.78, C.white, 0.2, C.line, {
    type: 'outer', color: '000000', opacity: 0.08, blur: 1.5, angle: 45, distance: 1
  });
  circle(s, 10.62, 2.99, 0.78, C.blue, '…', C.white, 24);
  text(s, 'iMessage', 9.86, 3.91, 2.3, 0.34, { fontSize: 20, bold: true, align: 'center' });
  text(s, 'Ask about affordability', 9.88, 4.51, 2.3, 0.27, { fontSize: 11, bold: true, color: C.ink, align: 'center' });
  text(s, 'Receive proactive coaching', 9.88, 4.94, 2.3, 0.27, { fontSize: 11, bold: true, color: C.ink, align: 'center' });
  text(s, 'Send a missing receipt', 9.88, 5.37, 2.3, 0.27, { fontSize: 11, bold: true, color: C.ink, align: 'center' });
  text(s, 'Correct a category naturally', 9.88, 5.8, 2.3, 0.27, { fontSize: 11, bold: true, color: C.ink, align: 'center' });

  roundRect(s, 2.72, 6.76, 7.9, 0.42, C.mint, 0.16);
  text(s, 'BANK DATA = merchant-level truth     +     RECEIPT DATA = item-level truth', 2.98, 6.84, 7.38, 0.24, { color: C.green, fontSize: 11.5, bold: true, align: 'center' });
  s.addNotes('Architecture diagram: open banking, dedicated receipt email and receipt photos combine in the Penny model, then surface through iMessage.');
}

// Slide 3 — real Figma prototype
{
  const s = pptx.addSlide('DARK');
  tag(s, '03  FIGMA PROTOTYPE', true);
  text(s, 'One conversation. A complete financial picture.', 0.65, 0.93, 8.1, 0.52, { color: C.white, fontSize: 28, bold: true });
  text(s, 'Connect on demand → receive useful coaching → recover item-level context → correct it naturally.', 0.68, 1.48, 9.5, 0.34, { color: 'C9D9D0', fontSize: 13.5 });
  roundRect(s, 0.6, 1.98, 12.13, 5.08, C.white, 0.18, null, {
    type: 'outer', color: '000000', opacity: 0.22, blur: 2, angle: 45, distance: 2
  });
  s.addImage({ path: 'penny_figma_prototype.png', x: 0.72, y: 2.10, w: 11.89, h: 4.83 });
  s.addNotes('Actual Figma prototype showing the conversational onboarding, coaching and SKU-level receipt recovery flow.');
}

pptx.writeFile({ fileName: 'Penny_Product_Flow.pptx' });

