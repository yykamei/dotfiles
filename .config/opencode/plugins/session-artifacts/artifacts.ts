/**
 * Extracts pull request and issue URLs from completed shell tool output.
 *
 * Usage: `const artifacts = collectArtifacts("shell", { command: "gh pr create" }, result)`
 */
export type ArtifactKind = "pull-request" | "issue"

export interface Artifact {
  readonly kind: ArtifactKind
  readonly url: string
}

/** Structural subset of `Tool.Result`; keeps this module free of the plugin SDK. */
export interface ToolResult {
  readonly content?: unknown
}

interface CreationRule {
  readonly kind: ArtifactKind
  readonly subcommand: "pr" | "issue"
  readonly url: RegExp
}

// V2 exposes the tool as "shell"; "bash" covers older and compatibility tools.
const SHELL_TOOLS = new Set(["shell", "bash"])

const MAX_ARTIFACTS_PER_RESULT = 20

const HOST = String.raw`[A-Za-z0-9](?:[A-Za-z0-9.-]*[A-Za-z0-9])?(?::\d{1,5})?`
const NAME = String.raw`[A-Za-z0-9._-]+`

const CREATION_RULES: readonly CreationRule[] = [
  {
    kind: "pull-request",
    subcommand: "pr",
    url: new RegExp(String.raw`https:\/\/${HOST}\/${NAME}\/${NAME}\/pull\/\d+(?![\w-])`, "g"),
  },
  {
    kind: "issue",
    subcommand: "issue",
    url: new RegExp(String.raw`https:\/\/${HOST}\/${NAME}\/${NAME}\/issues\/\d+(?![\w-])`, "g"),
  },
]

const LABELS: Readonly<Record<ArtifactKind, string>> = {
  "pull-request": "PR",
  issue: "Issue",
}

const ENV_ASSIGNMENTS = /^(?:[A-Za-z_][A-Za-z0-9_]*=\S*\s+)*/

function commandText(input: unknown): string {
  if (typeof input === "string") return input
  if (input === null || typeof input !== "object") return ""
  const command = (input as { command?: unknown }).command
  return typeof command === "string" ? command : ""
}

function resultText(result: ToolResult | undefined): string {
  if (!result) return ""
  if (typeof result.content === "string") return result.content
  if (!Array.isArray(result.content)) return ""
  const parts: string[] = []
  for (const part of result.content) {
    if (part === null || typeof part !== "object") continue
    const candidate = part as { type?: unknown; text?: unknown }
    if (candidate.type === "text" && typeof candidate.text === "string") parts.push(candidate.text)
  }
  return parts.join("\n")
}

// A separator inside quotes belongs to the same shell segment.
function splitSegments(command: string): string[] {
  const segments: string[] = []
  let current = ""
  let quote: '"' | "'" | undefined
  for (const char of command) {
    if (quote !== undefined) {
      current += char
      if (char === quote) quote = undefined
      continue
    }
    if (char === '"' || char === "'") {
      quote = char
      current += char
      continue
    }
    if (char === ";" || char === "&" || char === "|" || char === "\n") {
      segments.push(current)
      current = ""
      continue
    }
    current += char
  }
  segments.push(current)
  return segments
}

function hasCreationCommand(command: string, subcommand: "pr" | "issue"): boolean {
  return splitSegments(command).some((segment) => {
    const tokens = segment.trim().replace(ENV_ASSIGNMENTS, "").split(/\s+/)
    while (tokens[0] === "env" || tokens[0] === "command" || tokens[0] === "sudo") tokens.shift()
    while (tokens[0]?.includes("=")) tokens.shift()
    return tokens[0] === "gh" && tokens[1] === subcommand && tokens[2] === "create"
  })
}

function isAllowedUrl(value: string): boolean {
  let url: URL
  try {
    url = new URL(value)
  } catch {
    return false
  }
  if (url.protocol !== "https:") return false
  if (url.username !== "" || url.password !== "") return false
  if (url.hostname.startsWith("[") || url.hostname.includes(":")) return false
  return !/^\d{1,3}(?:\.\d{1,3}){3}$/.test(url.hostname)
}

export function collectArtifacts(tool: string, input: unknown, result: ToolResult | undefined): Artifact[] {
  if (!SHELL_TOOLS.has(tool)) return []
  const command = commandText(input)
  if (command === "") return []
  const output = resultText(result)
  if (output === "") return []

  const seen = new Set<string>()
  const artifacts: Artifact[] = []
  for (const rule of CREATION_RULES) {
    if (!hasCreationCommand(command, rule.subcommand)) continue
    for (const match of output.matchAll(rule.url)) {
      const url = match[0]
      if (!isAllowedUrl(url) || seen.has(url)) continue
      seen.add(url)
      artifacts.push({ kind: rule.kind, url })
      if (artifacts.length >= MAX_ARTIFACTS_PER_RESULT) return artifacts
    }
  }
  return artifacts
}

export function mergeArtifacts(existing: readonly Artifact[], incoming: readonly Artifact[]): Artifact[] {
  const seen = new Set(existing.map((artifact) => artifact.url))
  const merged = [...existing]
  for (const artifact of incoming) {
    if (seen.has(artifact.url)) continue
    seen.add(artifact.url)
    merged.push(artifact)
  }
  return merged
}

export function formatArtifacts(artifacts: readonly Artifact[]): string {
  if (artifacts.length === 0) return ""
  return ["成果物", ...artifacts.map((artifact) => `- ${LABELS[artifact.kind]}: ${artifact.url}`)].join("\n")
}
