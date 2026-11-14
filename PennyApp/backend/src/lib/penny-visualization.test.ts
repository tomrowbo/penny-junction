import { describe, expect, it } from "vitest";
import { buildPennyVisualization, pennyVisualizationSchema } from "./penny-visualization";

const coverage = { from: "2026-01-01", to: "2026-01-31" };
const institutions = ["S-Bank", "Nordea"];

describe("backend-owned Penny visualizations", () => {
  it("uses category totals unchanged and keeps tool references", () => {
    const visual = buildPennyVisualization("category_breakdown", {
      coverage, institutions, categories: [{ category: "Food", basket: "everyday", total: 182.35, transactionCount: 5 }],
    }, "call-food");
    expect(visual?.presentation).toEqual({ type: "bar", points: [{ id: "category-0", label: "Food", value: 182.35, referenceIDs: ["call-food"] }] });
    expect(visual?.period).toEqual(coverage);
    expect(visual?.sourceIDs).toEqual(["call-food"]);
    expect(visual?.institutions).toEqual(institutions);
  });

  it("includes unclassified spending rather than dropping evidence", () => {
    const visual = buildPennyVisualization("basket_profile", {
      coverage, institutions, baskets: [{ basket: "unclassified", total: 29, transactionCount: 1 }],
    }, "call-basket");
    expect(visual?.presentation).toMatchObject({ type: "bar", points: [{ label: "Unclassified", value: 29 }] });
  });

  it("labels comparison periods separately and retains both institutions", () => {
    const visual = buildPennyVisualization("compare_spending", {
      previous: { from: "2025-12-01", to: "2025-12-31", total: 400, institutions: ["Nordea"] },
      current: { ...coverage, total: 320, institutions: ["S-Bank"] }, change: -80,
    }, "call-compare");
    expect(visual?.presentation).toMatchObject({ type: "bar", points: [{ label: "2025-12-01–2025-12-31", value: 400 }, { label: "2026-01-01–2026-01-31", value: 320 }] });
    expect(visual?.period).toEqual({ from: "2025-12-01", to: "2026-01-31" });
    expect(visual?.institutions).toEqual(["Nordea", "S-Bank"]);
  });

  it("keeps horizon, historical coverage, confidence and assumptions visible for safe spending", () => {
    const visual = buildPennyVisualization("safe_to_spend", {
      coverage, institutions, safeToSpend: 75, horizonDays: 7, protectedBalance: 400,
      safeToSavePerMonth: 12, confidence: "low", assumptions: ["Income is irregular."],
    }, "call-safe");
    expect(visual?.presentation).toMatchObject({ type: "table", rows: [{ cells: ["Safe to spend · 7 days", "€75.00"] }, { cells: ["Reserved commitments", "€400.00"] }, { cells: ["Safe to save · monthly", "€12.00"] }] });
    expect(visual?.caption).toContain("low confidence");
    expect(visual?.caption).toContain("Income is irregular.");
    expect(visual?.caption).toContain("Historical coverage");
  });

  it("uses calculated scenario savings and describes the projection assumption", () => {
    const visual = buildPennyVisualization("simulate_reduction", {
      ...coverage, institutions, currentPeriodAmount: 200, periodSaving: 40, monthlySaving: 40,
      annualSaving: 480, percentage: 20, assumptions: ["Reduction must continue."],
    }, "call-sim");
    expect(visual?.presentation).toMatchObject({ type: "bar", points: [{ value: 200 }, { value: 160 }, { value: 40 }] });
    expect(visual?.caption).toContain("Reduction must continue.");
  });

  it("rejects malformed analytical values instead of publishing zeroes", () => {
    for (const total of [Number.NaN, Number.POSITIVE_INFINITY, -5, "99"]) {
      expect(buildPennyVisualization("category_breakdown", { coverage, institutions, categories: [{ category: "Food", total }] }, "call")).toBeUndefined();
    }
    expect(buildPennyVisualization("freeform", { type: "bar", value: 1000 }, "call")).toBeUndefined();
    expect(buildPennyVisualization("category_breakdown", { coverage, institutions, categories: [] }, "call")).toBeUndefined();
  });

  it("rejects impossible dates, reversed periods and unreferenced payloads", () => {
    for (const invalid of [{ from: "2026-02-30", to: "2026-03-01" }, { from: coverage.to, to: coverage.from }]) {
      expect(buildPennyVisualization("basket_profile", { coverage: invalid, institutions, baskets: [{ basket: "everyday", total: 1 }] }, "call")).toBeUndefined();
    }
    expect(buildPennyVisualization("basket_profile", { coverage, institutions, baskets: [{ basket: "everyday", total: 1 }] }, "")).toBeUndefined();
  });

  it("closes presentation types, units and table shapes", () => {
    const base = { id: "test", title: "Evidence", caption: "From connected accounts", period: coverage, institutions, unit: "eur", accessibilitySummary: "€1", sourceIDs: ["call"] };
    expect(pennyVisualizationSchema.safeParse({ ...base, presentation: { type: "html", html: "<script>" } }).success).toBe(false);
    expect(pennyVisualizationSchema.safeParse({ ...base, unit: "bitcoin", presentation: { type: "bar", points: [] } }).success).toBe(false);
    expect(pennyVisualizationSchema.safeParse({ ...base, presentation: { type: "table", columns: [{ id: "a", title: "Amount" }], rows: [{ id: "r", cells: ["1", "2"], referenceIDs: ["call"] }] } }).success).toBe(false);
    expect(pennyVisualizationSchema.safeParse({ ...base, presentation: { type: "progress", label: "Saved", value: 10, target: 0, referenceIDs: ["call"] } }).success).toBe(false);
    expect(pennyVisualizationSchema.safeParse({ ...base, presentation: { type: "bar", points: [{ id: "p", label: "Food", value: 1, referenceIDs: ["unknown"] }] } }).success).toBe(false);
  });
});
