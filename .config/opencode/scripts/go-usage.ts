#!/usr/bin/env bun
import { execFileSync } from "node:child_process"

type Meter = {
  percent: number
  limited: boolean
  resetsAt: number
}

type UsageLimits = {
  workspace?: { usageURL?: string }
  go?: {
    rolling: Meter
    weekly: Meter
    monthly: Meter
  }
}

type ModelUsage = {
  model: {
    providerID: string
    id: string
  }
  steps: number
  tokens: {
    input: number
    output: number
    reasoning: number
    cache: {
      read: number
      write: number
    }
  }
  cost: number
}

type SessionStats = {
  models?: ModelUsage[]
}

type Summary = {
  input: number
  output: number
  reasoning: number
  cacheRead: number
  cacheWrite: number
  total: number
  cost: number
}

function apiGet(path: string): unknown {
  const output = execFileSync("opencode", ["api", "get", path], {
    encoding: "utf8",
    stdio: ["ignore", "pipe", "pipe"],
    timeout: 15_000,
  })
  return JSON.parse(output)
}

/**
 * Returns the same local date and time one calendar month earlier, clamping
 * the day to the last day of the target month.
 *
 * Used to derive the start of the current Go billing period from the next
 * monthly reset.
 *
 * ```ts
 * previousMonth(new Date(2026, 2, 31)) // Feb 28, 2026
 * ```
 */
export function previousMonth(value: Date): Date {
  const year = value.getMonth() === 0 ? value.getFullYear() - 1 : value.getFullYear()
  const month = value.getMonth() === 0 ? 11 : value.getMonth() - 1
  const day = Math.min(value.getDate(), new Date(year, month + 1, 0).getDate())
  return new Date(year, month, day, value.getHours(), value.getMinutes(), value.getSeconds(), value.getMilliseconds())
}

/**
 * Returns whether a model consumes the paid OpenCode Go allowance.
 *
 * OpenCode Go's free models carry `free` in their ID (for example
 * `beam-free` and `longcat-2.5-free`). The API does not expose a separate
 * free flag, so this ID convention is the boundary between paid and free
 * usage.
 *
 * ```ts
 * isPaidGoModel({ providerID: "opencode-go", id: "beam-free" }) // false
 * ```
 */
export function isPaidGoModel(model: { providerID: string; id: string }): boolean {
  return model.providerID === "opencode-go" && !model.id.toLowerCase().includes("free")
}

/**
 * Aggregates paid OpenCode Go token usage and local cost into the totals
 * shown by `/go-usage`.
 *
 * Free Go models are excluded because they do not consume the paid
 * allowance. See `isPaidGoModel` for the boundary.
 *
 * ```ts
 * summarize(stats.models)
 * ```
 */
export function summarize(models: readonly ModelUsage[]): Summary {
  const selected = models.filter((entry) => isPaidGoModel(entry.model))
  const sum = (pick: (entry: ModelUsage) => number) => selected.reduce((total, entry) => total + pick(entry), 0)
  const input = sum((entry) => entry.tokens.input)
  const output = sum((entry) => entry.tokens.output)
  const reasoning = sum((entry) => entry.tokens.reasoning)
  const cacheRead = sum((entry) => entry.tokens.cache.read)
  const cacheWrite = sum((entry) => entry.tokens.cache.write)
  return {
    input,
    output,
    reasoning,
    cacheRead,
    cacheWrite,
    total: input + output + reasoning + cacheRead + cacheWrite,
    cost: sum((entry) => entry.cost),
  }
}

const METER_WIDTH = 10

function pad(value: number): string {
  return String(value).padStart(2, "0")
}

function formatDate(value: Date): string {
  return `${pad(value.getMonth() + 1)}/${pad(value.getDate())}`
}

/**
 * Renders a 10-block meter for a percentage.
 *
 * Used by `/go-usage` so the three Go windows read as bars instead of a
 * wall of numbers.
 *
 * ```ts
 * meterBar(67) // "███████░░░"
 * ```
 */
export function meterBar(percent: number, width = METER_WIDTH): string {
  const filled = Math.max(0, Math.min(width, Math.round((percent / 100) * width)))
  return "█".repeat(filled) + "░".repeat(width - filled)
}

/**
 * Formats a token count for the compact report.
 *
 * ```ts
 * compactTokens(17_848_121) // "17.8M"
 * ```
 */
export function compactTokens(value: number): string {
  if (value >= 999_500_000) return `${(value / 1_000_000_000).toFixed(1)}B`
  if (value >= 999_500) return `${(value / 1_000_000).toFixed(1)}M`
  if (value >= 1_000) return `${Math.round(value / 1_000)}K`
  return String(value)
}

/**
 * Formats the time until a Go window resets for the compact report.
 *
 * ```ts
 * relativeReset(now + 27 * 24 * 60 * 60_000, now) // "27d"
 * ```
 */
export function relativeReset(resetsAt: number, now: number): string {
  const minutes = Math.floor((resetsAt - now) / 60_000)
  if (minutes <= 0) return "now"
  if (minutes < 60) return `${minutes}m`
  const hours = Math.floor(minutes / 60)
  const mins = minutes % 60
  // Keep the reset column at six characters for the 32-character mobile row.
  if (hours < 24) {
    const withMinutes = `${hours}h ${mins}m`
    if (mins === 0 || withMinutes.length > 6) return `${hours}h`
    return withMinutes
  }
  const days = Math.floor(hours / 24)
  const hrs = hours % 24
  const withHours = `${days}d ${hrs}h`
  if (hrs === 0 || withHours.length > 6) return `${days}d`
  return withHours
}

/**
 * Formats one Go window row for the compact mobile chart.
 *
 * The row is designed to fit 32 characters so Mobile's code block does not
 * clip the reset column.
 *
 * ```ts
 * formatMeterRow("Weekly", { percent: 67, limited: false, resetsAt: now + 21 * 60 * 60_000 }, now)
 * // "Weekly    ███████░░░  67%    21h"
 * ```
 */
export function formatMeterRow(label: string, meter: Meter, now: number): string {
  const name = `${label}${meter.limited ? "!" : ""}`
  const percent = `${Math.round(meter.percent)}%`.padStart(4)
  return `${name.padEnd(9)} ${meterBar(meter.percent, METER_WIDTH)} ${percent} ${relativeReset(meter.resetsAt, now).padStart(6)}`
}

function formatHeader(): string {
  return `${"window".padEnd(9)} ${" ".repeat(METER_WIDTH)} ${"used".padStart(4)} ${"reset".padStart(6)}`
}

function formatCost(cost: number): string {
  return cost >= 100 ? `$${Math.round(cost)}` : `$${cost.toFixed(2)}`
}

function formatTokenLines(summary: Summary): string[] {
  const lines = [
    `input ${compactTokens(summary.input)} · output ${compactTokens(summary.output)}`,
    `reasoning ${compactTokens(summary.reasoning)} · cache rd ${compactTokens(summary.cacheRead)}`,
  ]
  if (summary.cacheWrite > 0) lines.push(`cache wr ${compactTokens(summary.cacheWrite)}`)
  lines.push(`total ${compactTokens(summary.total)} · local cost ${formatCost(summary.cost)}`)
  return lines
}

/**
 * Renders the `/go-usage` report lines.
 *
 * The code-block rows are designed to fit 32 characters on Mobile. The
 * Console link sits outside the code block so it renders as a link.
 *
 * ```ts
 * renderReport(limits, stats, new Date())
 * ```
 */
export function renderReport(
  limits: UsageLimits,
  stats: SessionStats | undefined,
  now: Date,
  tokenError?: string,
): string[] {
  const go = limits.go
  if (!go) return []
  const monthlyReset = new Date(go.monthly.resetsAt)
  const periodStart = previousMonth(monthlyReset)
  const lines = ["```text", "OpenCode Go", "", formatHeader()]
  for (const [label, meter] of [
    ["Rolling", go.rolling],
    ["Weekly", go.weekly],
    ["Monthly", go.monthly],
  ] as const) {
    lines.push(formatMeterRow(label, meter, now.getTime()))
  }
  if ([go.rolling, go.weekly, go.monthly].some((meter) => meter.limited)) lines.push("! = limited")
  lines.push("", `Billing ~${formatDate(periodStart)}–${formatDate(monthlyReset)}`, "paid Go · this machine")
  if (stats) lines.push(...formatTokenLines(summarize(stats.models ?? [])))
  lines.push("```", "")
  if (tokenError) lines.push(`Billing-period tokens are unavailable: ${tokenError}`, "")
  const usageURL = limits.workspace?.usageURL
  if (usageURL) lines.push(`[Exact allowance dollars](${usageURL})`)
  return lines
}

function main(): number {
  let limits: { data?: UsageLimits | null }
  try {
    limits = apiGet("/api/experimental/usage/limits") as { data?: UsageLimits | null }
  } catch (error) {
    console.log(`OpenCode Go usage is unavailable: ${error instanceof Error ? error.message : String(error)}`)
    return 0
  }

  const data = limits.data
  if (data === null) {
    console.log("Not signed in to OpenCode Console.")
    return 0
  }
  if (!data) {
    console.log("OpenCode Go usage is unavailable.")
    return 0
  }
  const go = data.go
  if (!go) {
    console.log("OpenCode Go is not available for this workspace (no Go subscription).")
    return 0
  }

  const now = new Date()
  const monthlyReset = new Date(go.monthly.resetsAt)
  const periodStart = previousMonth(monthlyReset)
  let stats: SessionStats | undefined
  let tokenError: string | undefined
  try {
    const response = apiGet(
      `/api/experimental/session/stats?from=${periodStart.getTime()}&to=${now.getTime()}&tools=none`,
    ) as { data?: SessionStats | null }
    stats = response.data ?? undefined
  } catch (error) {
    tokenError = error instanceof Error ? error.message : String(error)
  }

  for (const line of renderReport(data, stats, now, tokenError)) console.log(line)
  return 0
}

if (import.meta.main) process.exit(main())
