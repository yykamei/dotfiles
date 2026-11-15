import { describe, expect, test } from "bun:test"
import {
  compactTokens,
  formatMeterRow,
  isPaidGoModel,
  meterBar,
  previousMonth,
  relativeReset,
  renderReport,
  summarize,
} from "./go-usage"

describe("meterBar", () => {
  test("renders empty, half, and full meters", () => {
    expect(meterBar(0)).toBe("░░░░░░░░░░")
    expect(meterBar(50)).toBe("█████░░░░░")
    expect(meterBar(100)).toBe("██████████")
  })

  test("rounds partial blocks", () => {
    expect(meterBar(67)).toBe("███████░░░")
  })
})

describe("compactTokens", () => {
  test("formats millions, thousands, and small values", () => {
    expect(compactTokens(17_848_121)).toBe("17.8M")
    expect(compactTokens(520_675_328)).toBe("520.7M")
    expect(compactTokens(1_500)).toBe("2K")
    expect(compactTokens(999_500)).toBe("1.0M")
    expect(compactTokens(999_500_000)).toBe("1.0B")
    expect(compactTokens(1_200_000_000)).toBe("1.2B")
    expect(compactTokens(0)).toBe("0")
  })
})

describe("relativeReset", () => {
  const now = new Date(2026, 10, 15, 12, 0).getTime()

  test("formats minutes, hours, and days within six characters", () => {
    expect(relativeReset(now - 1, now)).toBe("now")
    expect(relativeReset(now + 30 * 60_000, now)).toBe("30m")
    expect(relativeReset(now + (3 * 60 + 12) * 60_000, now)).toBe("3h 12m")
    expect(relativeReset(now + (23 * 60 + 37) * 60_000, now)).toBe("23h")
    expect(relativeReset(now + 26 * 60 * 60_000, now)).toBe("1d 2h")
    expect(relativeReset(now + (2 * 24 + 23) * 60 * 60_000, now)).toBe("2d 23h")
    expect(relativeReset(now + (26 * 24 + 21) * 60 * 60_000, now)).toBe("26d")
    expect(relativeReset(now + 27 * 24 * 60 * 60_000, now)).toBe("27d")
  })
})

describe("formatMeterRow", () => {
  const now = new Date(2026, 10, 15, 12, 0).getTime()

  test("renders the expected aligned row", () => {
    expect(
      formatMeterRow("Weekly", { percent: 67, limited: false, resetsAt: now + 21 * 60 * 60_000 }, now),
    ).toBe("Weekly    ███████░░░  67%    21h")
  })

  test("keeps a limited row within the mobile width", () => {
    const row = formatMeterRow("Rolling", { percent: 100, limited: true, resetsAt: now + 27 * 24 * 60 * 60_000 }, now)

    expect(row.length).toBeLessThanOrEqual(32)
    expect(row).toContain("Rolling!")
    expect(row).toContain("27d")
  })

  test("keeps a two-digit-hour reset row within the mobile width", () => {
    const row = formatMeterRow("Weekly", { percent: 73, limited: false, resetsAt: now + (23 * 60 + 37) * 60_000 }, now)

    expect(row.length).toBeLessThanOrEqual(32)
    expect(row).toContain("23h")
  })

  test("keeps a multi-day reset row within the mobile width", () => {
    const row = formatMeterRow("Monthly", { percent: 36, limited: false, resetsAt: now + (26 * 24 + 21) * 60 * 60_000 }, now)

    expect(row.length).toBeLessThanOrEqual(32)
    expect(row).toContain("26d")
  })
})

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
      input: 10,
      output: 2,
      reasoning: 1,
      cacheRead: 3,
      cacheWrite: 4,
      total: 20,
      cost: 0,
    })
  })

  test("sums cost across paid Go models", () => {
    const tokens = { input: 0, output: 0, reasoning: 0, cache: { read: 0, write: 0 } }
    const summary = summarize([
      { model: { providerID: "opencode-go", id: "a-model" }, steps: 1, tokens, cost: 2.5 },
      { model: { providerID: "opencode-go", id: "b-model" }, steps: 1, tokens, cost: 3.25 },
      { model: { providerID: "opencode-go", id: "beam-free" }, steps: 1, tokens, cost: 9 },
    ])

    expect(summary.cost).toBeCloseTo(5.75)
    expect(summary.total).toBe(0)
  })

  test("returns zeroes when no paid Go model is present", () => {
    expect(summarize([])).toEqual({
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

describe("renderReport", () => {
  test("keeps every code-block line within 32 characters for extreme values", () => {
    const now = new Date(2026, 10, 15, 12, 0)
    const limits = {
      workspace: { usageURL: "https://opencode.ai/console/example" },
      go: {
        rolling: { percent: 100, limited: true, resetsAt: now.getTime() + (23 * 60 + 37) * 60_000 },
        weekly: { percent: 73, limited: false, resetsAt: now.getTime() + (6 * 24 + 3) * 60 * 60_000 },
        monthly: { percent: 36, limited: false, resetsAt: now.getTime() + (26 * 24 + 21) * 60 * 60_000 },
      },
    }
    const stats = {
      models: [
        {
          model: { providerID: "opencode-go", id: "deepseek-v4.1-flash" },
          steps: 1,
          tokens: {
            input: 1_200_000_000,
            output: 1_200_000_000,
            reasoning: 2_800_000_000,
            cache: { read: 1_200_000_000, write: 3_400_000 },
          },
          cost: 1234.56,
        },
      ],
    }

    const lines = renderReport(limits, stats, now)
    const start = lines.indexOf("```text")
    const end = lines.indexOf("```", start + 1)

    expect(start).toBeGreaterThanOrEqual(0)
    expect(end).toBeGreaterThan(start)
    expect(lines).toContain("OpenCode Go")
    expect(lines).not.toContain("OpenCode Go · free model")
    for (const line of lines.slice(start + 1, end)) {
      expect(line.length).toBeLessThanOrEqual(32)
    }
  })
})
