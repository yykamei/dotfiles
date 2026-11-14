import { describe, expect, test } from "bun:test"
import { isPaidGoModel, previousMonth, summarize } from "./go-usage"

describe("previousMonth", () => {
  test("moves to the same day in the previous month", () => {
    expect(previousMonth(new Date(2026, 11, 12, 7, 12))).toEqual(new Date(2026, 10, 12, 7, 12))
  })

  test("clamps the day to the previous month's last day", () => {
    expect(previousMonth(new Date(2026, 2, 31, 0, 0))).toEqual(new Date(2026, 1, 28, 0, 0))
  })

  test("handles a leap year", () => {
    expect(previousMonth(new Date(2024, 2, 31, 0, 0))).toEqual(new Date(2024, 1, 29, 0, 0))
  })

  test("moves from January to December of the previous year", () => {
    expect(previousMonth(new Date(2026, 0, 15, 0, 0))).toEqual(new Date(2025, 11, 15, 0, 0))
  })

  test("clamps the day to a 30-day previous month", () => {
    expect(previousMonth(new Date(2026, 4, 31, 0, 0))).toEqual(new Date(2026, 3, 30, 0, 0))
  })
})

describe("isPaidGoModel", () => {
  test("excludes free Go models case-insensitively", () => {
    expect(isPaidGoModel({ providerID: "opencode-go", id: "beam-free" })).toBe(false)
    expect(isPaidGoModel({ providerID: "opencode-go", id: "BEAM-FREE" })).toBe(false)
    expect(isPaidGoModel({ providerID: "opencode-go", id: "deepseek-v4.1-flash" })).toBe(true)
    expect(isPaidGoModel({ providerID: "anthropic", id: "claude" })).toBe(false)
  })
})

describe("summarize", () => {
  test("keeps paid Go models and drops free and other providers", () => {
    const summary = summarize([
      {
        model: { providerID: "opencode-go", id: "deepseek-v4.1-flash" },
        steps: 2,
        tokens: { input: 10, output: 2, reasoning: 1, cache: { read: 3, write: 4 } },
        cost: 0,
      },
      {
        model: { providerID: "opencode-go", id: "beam-free" },
        steps: 9,
        tokens: { input: 100, output: 100, reasoning: 0, cache: { read: 0, write: 0 } },
        cost: 0,
      },
      {
        model: { providerID: "anthropic", id: "claude" },
        steps: 5,
        tokens: { input: 100, output: 100, reasoning: 0, cache: { read: 0, write: 0 } },
        cost: 1,
      },
    ])

    expect(summary).toEqual({
      models: ["deepseek-v4.1-flash"],
      steps: 2,
      input: 10,
      output: 2,
      reasoning: 1,
      cacheRead: 3,
      cacheWrite: 4,
      total: 20,
      cost: 0,
    })
  })

  test("sums cost and dedupes and sorts paid Go model ids", () => {
    const tokens = { input: 0, output: 0, reasoning: 0, cache: { read: 0, write: 0 } }
    const summary = summarize([
      { model: { providerID: "opencode-go", id: "z-model" }, steps: 1, tokens, cost: 2.5 },
      { model: { providerID: "opencode-go", id: "a-model" }, steps: 1, tokens, cost: 3.25 },
      { model: { providerID: "opencode-go", id: "z-model" }, steps: 1, tokens, cost: 1.25 },
    ])

    expect(summary.models).toEqual(["a-model", "z-model"])
    expect(summary.steps).toBe(3)
    expect(summary.cost).toBeCloseTo(7)
  })

  test("returns zeroes when no paid Go model is present", () => {
    expect(summarize([])).toEqual({
      models: [],
      steps: 0,
      input: 0,
      output: 0,
      reasoning: 0,
      cacheRead: 0,
      cacheWrite: 0,
      total: 0,
      cost: 0,
    })
  })
})
