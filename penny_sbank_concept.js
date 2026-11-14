const pptxgen = require('pptxgenjs');

const pptx = new pptxgen();
pptx.layout = 'LAYOUT_WIDE';
pptx.author = 'Penny';
pptx.company = 'Junction 2026';
pptx.subject = 'S-Bank financial coach concept';
pptx.title = 'Penny — The Complete Financial Picture';
pptx.lang = 'en-GB';
pptx.theme = { headFontFace: 'Arial', bodyFontFace: 'Arial', lang: 'en-GB' };

const C = {
  forest: '123A2A',
  green: '1D7348',
  midGreen: '238653',
  mint: 'EAF5EE',
  pale: 'F7F9F7',
  white: 'FFFFFF',
  ink: '14231B',
  muted: '596860',
  line: 'D4DDD8',
  yellow: 'FFF2C7',
  gold: '6A5100',
  blue: 'EAF3FF'
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
    fit: opts.fit || 'shrink',
    isTextBox: true,
    ...opts
  });
}

function roundRect(slide, x, y, w, h, fill, line = fill, radius = 0.18) {
  slide.addShape(pptx.ShapeType.roundRect, {
    x, y, w, h,
    rectRadius: radius,
    fill: { color: fill },
    line: { color: line, width: 1 }
  });
}

function label(slide, value, dark = false) {
  roundRect(slide, 0.62, 0.5, 2.35, 0.36, dark ? '24513F' : C.mint, dark ? '24513F' : C.mint);
  text(slide, value, 0.78, 0.55, 2.05, 0.22, {
    color: dark ? 'C9E4D4' : C.green,
    bold: true,
    fontSize: 10,
    charSpacing: 1.2
  });
}

// Slide 1 — the gap
{
  const s = pptx.addSlide();
  s.background = { color: C.forest };
  label(s, '01  THE PROBLEM', true);
  text(s, 'Your bank sees only part\nof your financial life.', 0.68, 1.18, 6.0, 1.35, {
    color: C.white, fontSize: 34, bold: true, valign: 'top'
  });
  text(s, 'Transaction totals are not enough to give trustworthy advice.', 0.7, 2.72, 5.45, 0.42, {
    color: 'C9D9D0', fontSize: 17
  });

  roundRect(s, 0.7, 3.55, 4.8, 1.25, '1D4A38', '315E4A');
  text(s, 'WHAT S-BANK SEES', 1.02, 3.8, 1.8, 0.22, { color: 'BCE0CB', fontSize: 9.5, bold: true, charSpacing: 1.1 });
  text(s, 'Prisma', 1.02, 4.15, 1.4, 0.32, { color: C.white, fontSize: 18, bold: true });
  text(s, '€63.20', 4.02, 4.05, 1.05, 0.42, { color: C.white, fontSize: 23, bold: true, align: 'right' });
  text(s, 'Merchant · amount · timestamp', 1.02, 4.5, 2.6, 0.2, { color: 'B9CFC3', fontSize: 10.5 });

  text(s, 'Two critical gaps', 7.05, 1.25, 3.1, 0.42, { color: C.white, fontSize: 23, bold: true });
  roundRect(s, 7.02, 1.95, 5.55, 1.65, C.yellow, C.yellow);
  text(s, 'Mortgage at another bank', 7.42, 2.27, 3.55, 0.35, { color: C.ink, fontSize: 19, bold: true });
  text(s, 'Missing from affordability, debt and safe-to-spend calculations.', 7.42, 2.78, 4.5, 0.48, { color: C.gold, fontSize: 13.5, valign: 'top' });

  roundRect(s, 7.02, 3.9, 5.55, 1.65, C.yellow, C.yellow);
  text(s, 'No product-level detail', 7.42, 4.22, 3.55, 0.35, { color: C.ink, fontSize: 19, bold: true });
  text(s, 'The total says where you shopped—not what you actually bought.', 7.42, 4.73, 4.5, 0.48, { color: C.gold, fontSize: 13.5, valign: 'top' });

  text(s, 'Partial data creates partial advice.', 0.7, 6.15, 6.3, 0.5, { color: C.white, fontSize: 25, bold: true });
  text(s, 'Penny completes the picture before it coaches.', 7.04, 6.18, 5.25, 0.42, { color: 'BCE0CB', fontSize: 16.5, bold: true, align: 'right' });
  s.addNotes('Open with the data problem: banking transaction history is incomplete at both customer and product level.');
}

// Slide 2 — simple architecture visual
{
  const s = pptx.addSlide();
  s.background = { color: C.pale };
  s.addImage({ path: 'penny_architecture.png', x: 0, y: 0, w: 13.333, h: 7.5 });
  s.addNotes('Open banking fills cross-bank liabilities and balances. Loyalty data plus attached receipts fill product-level detail.');
}

// Slide 3 — S-mobiili product concept
{
  const s = pptx.addSlide();
  s.background = { color: C.pale };
  s.addImage({ path: 'penny_sbank_mockup.png', x: 0, y: 0, w: 13.333, h: 7.5 });
  s.addNotes('Prototype flow: tap a transaction, add its missing receipt, then receive product-level financial coaching inside an S-mobiili concept.');
}

// Slide 4 — strategic advantage
{
  const s = pptx.addSlide();
  s.background = { color: C.forest };
  label(s, '04  WHY S-BANK', true);
  text(s, 'S-Bank has a data advantage\nother banks cannot easily copy.', 0.68, 1.15, 6.1, 1.25, {
    color: C.white, fontSize: 31, bold: true, valign: 'top'
  });

  text(s, '49.0%', 0.68, 2.83, 2.4, 0.82, { color: C.white, fontSize: 46, bold: true });
  text(s, 'of Finnish grocery sales flow through S Group', 0.72, 3.7, 3.95, 0.55, { color: 'C9D9D0', fontSize: 15.5, bold: true, valign: 'top' });
  text(s, '2.71m', 0.68, 4.62, 2.2, 0.72, { color: 'BCE0CB', fontSize: 38, bold: true });
  text(s, 'cooperative members', 0.72, 5.35, 2.5, 0.3, { color: 'C9D9D0', fontSize: 14.5, bold: true });

  const layers = [
    ['S-Bank financial data', 'Accounts, balances and transaction history'],
    ['S Group loyalty + receipts', 'Automatic product-level purchase detail'],
    ['Open banking', 'Mortgages, loans and accounts held elsewhere']
  ];
  layers.forEach((layer, i) => {
    const y = 1.35 + i * 1.38;
    roundRect(s, 7.05, y, 5.55, 1.05, i === 1 ? C.mint : C.white, i === 1 ? C.mint : C.white);
    text(s, layer[0], 7.42, y + 0.18, 3.9, 0.3, { color: i === 1 ? C.green : C.ink, fontSize: 16.5, bold: true });
    text(s, layer[1], 7.42, y + 0.55, 4.55, 0.28, { color: C.muted, fontSize: 11.5 });
  });
  roundRect(s, 7.05, 5.58, 5.55, 0.9, C.midGreen, C.midGreen);
  text(s, 'Penny: the complete financial picture', 7.4, 5.83, 4.85, 0.34, { color: C.white, fontSize: 18, bold: true, align: 'center' });

  text(s, 'The advantage is not chat. It is the combination of data.', 0.7, 6.55, 11.8, 0.38, { color: C.white, fontSize: 22, bold: true });
  text(s, 'Sources: Finnish Grocery Trade Association (2025); S Group key figures (2025).', 0.72, 7.08, 6.5, 0.18, { color: '9EB8AA', fontSize: 8.5 });
  s.addNotes('Close on defensibility: S-Bank can combine banking, loyalty-linked products and external-bank data in one experience.');
}

pptx.writeFile({ fileName: 'Penny_SBank_Concept.pptx' });
