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
  models: string[]
  steps: number
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
 * Aggregates paid OpenCode Go model usage into the totals shown by
 * `/go-usage`.
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
    models: [...new Set(selected.map((entry) => entry.model.id))].sort(),
    steps: sum((entry) => entry.steps),
    input,
    output,
    reasoning,
    cacheRead,
    cacheWrite,
    total: input + output + reasoning + cacheRead + cacheWrite,
    cost: sum((entry) => entry.cost),
  }
}

function pad(value: number): string {
  return String(value).padStart(2, "0")
}

function formatTime(value: Date): string {
  return `${value.getFullYear()}-${pad(value.getMonth() + 1)}-${pad(value.getDate())} ${pad(value.getHours())}:${pad(value.getMinutes())}`
}

function formatInteger(value: number): string {
  return new Intl.NumberFormat("en-US").format(value)
}

function printUsageURL(limits: UsageLimits | null | undefined): void {
  const usageURL = limits?.workspace?.usageURL
  if (usageURL) console.log(`Exact allowance dollars: ${usageURL}`)
}

function main(): number {
  let limits: { data?: UsageLimits | null }
  try {
    limits = apiGet("/api/experimental/usage/limits") as { data?: UsageLimits | null }
  } catch (error) {
    console.log(`OpenCode Go usage is unavailable: ${error instanceof Error ? error.message : String(error)}`)
    return 0
  }

  if (limits.data === null) {
    console.log("Not signed in to OpenCode Console.")
    return 0
  }

  const go = limits.data?.go
  if (!go) {
    console.log("OpenCode Go is not available for this workspace (no Go subscription).")
    return 0
  }

  const now = new Date()
  const timezone = Intl.DateTimeFormat().resolvedOptions().timeZone
  const monthlyReset = new Date(go.monthly.resetsAt)
  const periodStart = previousMonth(monthlyReset)

  console.log("OpenCode Go usage")
  console.log()
  for (const [label, meter] of [
    ["Rolling (5h)", go.rolling],
    ["Weekly", go.weekly],
    ["Monthly", go.monthly],
  ] as const) {
    const suffix = meter.limited ? " (limited)" : ""
    console.log(`${label}: ${Math.round(meter.percent)}% used${suffix} (resets at ${formatTime(new Date(meter.resetsAt))})`)
  }

  console.log()
  console.log(
    `Estimated billing period: ${formatTime(periodStart)} – ${formatTime(monthlyReset)} (${timezone})`,
  )

  let stats: { data?: SessionStats | null }
  try {
    stats = apiGet(
      `/api/experimental/session/stats?from=${periodStart.getTime()}&to=${now.getTime()}&tools=none`,
    ) as { data?: SessionStats | null }
  } catch (error) {
    console.log(`Billing-period tokens are unavailable: ${error instanceof Error ? error.message : String(error)}`)
    printUsageURL(limits.data)
    return 0
  }

  const summary = summarize(stats.data?.models ?? [])
  console.log("Paid Go usage on this machine (free models excluded):")
  console.log(`  Models: ${summary.models.length > 0 ? summary.models.join(", ") : "none"}`)
  console.log(`  Steps: ${formatInteger(summary.steps)}`)
  console.log(`  Input tokens: ${formatInteger(summary.input)}`)
  console.log(`  Output tokens: ${formatInteger(summary.output)}`)
  console.log(`  Reasoning tokens: ${formatInteger(summary.reasoning)}`)
  console.log(`  Cache read tokens: ${formatInteger(summary.cacheRead)}`)
  console.log(`  Cache write tokens: ${formatInteger(summary.cacheWrite)}`)
  console.log(`  Total tokens: ${formatInteger(summary.total)}`)
  console.log(`  Local cost: $${summary.cost.toFixed(2)} (Go plan; local data does not include allowance dollars)`)

  printUsageURL(limits.data)
  return 0
}

if (import.meta.main) process.exit(main())
