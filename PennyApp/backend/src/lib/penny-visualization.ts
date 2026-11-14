import { z } from "zod";

const text = z.string().trim().min(1);
const references = z.array(text).min(1);
const finite = z.number().finite();
const money = finite.nonnegative();
const date = z.string().regex(/^\d{4}-\d{2}-\d{2}$/).refine((value) => {
  const parsed = new Date(`${value}T00:00:00Z`);
  return !Number.isNaN(parsed.getTime()) && parsed.toISOString().slice(0, 10) === value;
});
const period = z.object({ from: date, to: date }).strict().refine((value) => value.from <= value.to);
const point = z.object({ id: text, label: text, value: finite, referenceIDs: references }).strict();
const column = z.object({ id: text, title: text }).strict();
const row = z.object({ id: text, cells: z.array(z.string()), referenceIDs: references }).strict();
const presentation = z.discriminatedUnion("type", [
  z.object({ type: z.literal("bar"), points: z.array(point).min(1) }).strict(),
  z.object({ type: z.literal("line"), points: z.array(point).min(1) }).strict(),
  z.object({ type: z.literal("progress"), label: text, value: money, target: finite.positive(), referenceIDs: references }).strict(),
  z.object({ type: z.literal("table"), columns: z.array(column).min(1), rows: z.array(row).min(1) }).strict(),
]);

/** Wire format shared with PennyVisualization.swift. No executable or free-form UI fields. */
export const pennyVisualizationSchema = z.object({
  id: text,
  title: text,
  caption: text,
  period,
  institutions: z.array(text).min(1),
  unit: z.enum(["eur", "count", "percent"]),
  accessibilitySummary: text,
  sourceIDs: references,
  presentation,
}).strict().superRefine((visual, context) => {
  const content = visual.presentation;
  const items = content.type === "table" ? content.rows : content.type === "progress" ? [content] : content.points;
  if (items.some((item) => item.referenceIDs.some((id) => !visual.sourceIDs.includes(id)))) {
    context.addIssue({ code: "custom", message: "Every element must reference a declared source." });
  }
  const unique = (ids: string[]) => new Set(ids).size === ids.length;
  if (content.type === "table") {
    if (!unique(content.columns.map((item) => item.id)) || !unique(content.rows.map((item) => item.id)) || content.rows.some((item) => item.cells.length !== content.columns.length)) {
      context.addIssue({ code: "custom", message: "Table IDs must be unique and rows must match columns." });
    }
  } else if (content.type !== "progress" && !unique(content.points.map((item) => item.id))) {
    context.addIssue({ code: "custom", message: "Point IDs must be unique." });
  }
});

export type PennyVisualization = z.infer<typeof pennyVisualizationSchema>;
type Context = { period: z.infer<typeof period>; institutions: string[] };
const eur = (amount: number) => new Intl.NumberFormat("en-IE", { style: "currency", currency: "EUR" }).format(amount);
const span = (range: Context["period"]) => `${range.from}–${range.to}`;
const baskets: Record<string, string> = {
  mandatory_regular: "Mandatory and regular", mandatory_irregular: "Mandatory and irregular",
  everyday: "Everyday spending", unclassified: "Unclassified",
};

function barVisual(referenceID: string, title: string, caption: string, context: Context, values: Array<{ id: string; label: string; value: number }>): PennyVisualization {
  const points = values.map((value) => ({ ...value, referenceIDs: [referenceID] }));
  return pennyVisualizationSchema.parse({
    id: referenceID, title, caption, ...context, unit: "eur", sourceIDs: [referenceID],
    accessibilitySummary: `${title}. ${span(context.period)}. ${values.map((value) => `${value.label}: ${eur(value.value)}`).join(". ")}. ${caption}`,
    presentation: { type: "bar", points },
  });
}

const categoriesResult = z.object({ coverage: period, institutions: z.array(text).min(1), categories: z.array(z.object({ category: text, total: money })).min(1) });
const basketsResult = z.object({ coverage: period, institutions: z.array(text).min(1), baskets: z.array(z.object({ basket: z.enum(["mandatory_regular", "mandatory_irregular", "everyday", "unclassified"]), total: money })).min(1) });
const summaryResult = z.object({ from: date, to: date, total: money, institutions: z.array(text).min(1) }).refine((value) => value.from <= value.to);
const comparisonResult = z.object({ current: summaryResult, previous: summaryResult });
const safeResult = z.object({
  coverage: period, institutions: z.array(text).min(1), safeToSpend: money,
  horizonDays: z.number().int().min(1).max(31), protectedBalance: money, safeToSavePerMonth: money,
  confidence: z.enum(["high", "medium", "low"]), assumptions: z.array(text),
});
const simulationResult = z.object({
  from: date, to: date, institutions: z.array(text).min(1), currentPeriodAmount: money,
  periodSaving: money, monthlySaving: money, annualSaving: money, percentage: finite.min(1).max(100), assumptions: z.array(text),
}).refine((value) => value.from <= value.to && value.periodSaving <= value.currentPeriodAmount);

export function buildCategoryVisualization(result: z.infer<typeof categoriesResult>, referenceID: string): PennyVisualization {
  return barVisual(referenceID, "Spending by category", "Actual spending in the selected period.", { period: result.coverage, institutions: result.institutions },
    result.categories.slice(0, 5).map((item, index) => ({ id: `category-${index}`, label: item.category, value: item.total })));
}

export function buildBasketVisualization(result: z.infer<typeof basketsResult>, referenceID: string): PennyVisualization {
  return barVisual(referenceID, "Your spending baskets", "Actual spending in the selected period.", { period: result.coverage, institutions: result.institutions },
    result.baskets.map((item, index) => ({ id: `basket-${index}`, label: baskets[item.basket], value: item.total })));
}

export function buildComparisonVisualization(result: z.infer<typeof comparisonResult>, referenceID: string): PennyVisualization {
  const from = [result.previous.from, result.current.from].sort()[0];
  const to = [result.previous.to, result.current.to].sort().at(-1)!;
  return barVisual(referenceID, "Spending comparison", "Totals cover the labelled periods; periods may differ in length.",
    { period: { from, to }, institutions: [...new Set([...result.previous.institutions, ...result.current.institutions])].sort() },
    [{ id: "previous", label: span(result.previous), value: result.previous.total }, { id: "current", label: span(result.current), value: result.current.total }]);
}

export function buildSafeToSpendVisualization(result: z.infer<typeof safeResult>, referenceID: string): PennyVisualization {
  const rows = [
    { id: "spend", cells: [`Safe to spend · ${result.horizonDays} days`, eur(result.safeToSpend)], referenceIDs: [referenceID] },
    { id: "reserved", cells: ["Kept aside for unexpected costs", eur(result.protectedBalance)], referenceIDs: [referenceID] },
    { id: "save", cells: ["Safe to save · monthly", eur(result.safeToSavePerMonth)], referenceIDs: [referenceID] },
  ];
  const caption = `Estimate · ${result.confidence} confidence. Historical coverage is shown below. ${result.assumptions.join(" ")}`.trim();
  return pennyVisualizationSchema.parse({
    id: referenceID, title: "Safe to spend", caption, period: result.coverage, institutions: result.institutions,
    unit: "eur", sourceIDs: [referenceID],
    accessibilitySummary: `${rows.map((row) => row.cells.join(": ")).join(". ")}. ${caption}`,
    presentation: { type: "table", columns: [{ id: "measure", title: "Measure" }, { id: "amount", title: "Amount" }], rows },
  });
}

export function buildSimulationVisualization(result: z.infer<typeof simulationResult>, referenceID: string): PennyVisualization {
  const remaining = Math.round((result.currentPeriodAmount - result.periodSaving + Number.EPSILON) * 100) / 100;
  return barVisual(referenceID, "Spending reduction scenario", `Illustration for a ${result.percentage}% reduction. ${result.assumptions.join(" ")}`,
    { period: { from: result.from, to: result.to }, institutions: result.institutions },
    [{ id: "current", label: "Current spending", value: result.currentPeriodAmount }, { id: "scenario", label: "After reduction", value: remaining }, { id: "saving", label: "Potential saving", value: result.periodSaving }]);
}

/** Call only with executeTool output, never model-authored arguments or response text. */
export function buildPennyVisualization(toolName: string, result: Record<string, unknown>, referenceID: string): PennyVisualization | undefined {
  if (!text.safeParse(referenceID).success) return undefined;
  try {
    switch (toolName) {
      case "category_breakdown": return buildCategoryVisualization(categoriesResult.parse(result), referenceID);
      case "basket_profile": return buildBasketVisualization(basketsResult.parse(result), referenceID);
      case "compare_spending": return buildComparisonVisualization(comparisonResult.parse(result), referenceID);
      case "safe_to_spend": return buildSafeToSpendVisualization(safeResult.parse(result), referenceID);
      case "simulate_reduction": return buildSimulationVisualization(simulationResult.parse(result), referenceID);
      default: return undefined;
    }
  } catch {
    // A bad visual must not make a valid textual coaching response unavailable.
    return undefined;
  }
}
