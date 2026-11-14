import { describe, expect, test } from "bun:test"
import { collectArtifacts, formatArtifacts, mergeArtifacts } from "./artifacts"

const text = (value: string) => ({ content: [{ type: "text" as const, text: value }] })

describe("collectArtifacts", () => {
  test("collects the pull request URL printed by gh pr create", () => {
    const artifacts = collectArtifacts(
      "shell",
      { command: "gh pr create --title 'Add feature' --body 'Body'" },
      text("Creating pull request for feature into main in owner/repo\n\nhttps://github.com/owner/repo/pull/12\n"),
    )

    expect(artifacts).toEqual([{ kind: "pull-request", url: "https://github.com/owner/repo/pull/12" }])
  })

  test("collects the issue URL printed by gh issue create", () => {
    const artifacts = collectArtifacts(
      "shell",
      { command: "gh issue create --title 'Bug' --body 'Details'" },
      text("Creating issue in owner/repo\n\nhttps://github.com/owner/repo/issues/34\n"),
    )

    expect(artifacts).toEqual([{ kind: "issue", url: "https://github.com/owner/repo/issues/34" }])
  })

  test("reads a plain string result", () => {
    const artifacts = collectArtifacts(
      "shell",
      { command: "gh pr create --fill" },
      { content: "https://github.com/owner/repo/pull/1" },
    )

    expect(artifacts).toEqual([{ kind: "pull-request", url: "https://github.com/owner/repo/pull/1" }])
  })

  test("ignores calls that do not create an artifact", () => {
    const url = "https://github.com/owner/repo/pull/12"

    expect(collectArtifacts("shell", { command: "gh pr view 12 --json url --jq .url" }, text(url))).toEqual([])
    expect(collectArtifacts("read", { path: "notes.md" }, text(url))).toEqual([])
    expect(collectArtifacts("shell", { command: "gh pr create --fill" }, undefined)).toEqual([])
  })

  test("keeps only the URL kind that the command creates", () => {
    const artifacts = collectArtifacts(
      "shell",
      { command: "gh pr create --fill" },
      text("https://github.com/owner/repo/pull/12\nhttps://github.com/owner/repo/issues/34"),
    )

    expect(artifacts).toEqual([{ kind: "pull-request", url: "https://github.com/owner/repo/pull/12" }])
  })

  test("supports GitHub Enterprise hosts", () => {
    const artifacts = collectArtifacts(
      "shell",
      { command: "gh pr create --fill" },
      text("https://ghe.example.com/owner/repo/pull/56"),
    )

    expect(artifacts).toEqual([{ kind: "pull-request", url: "https://ghe.example.com/owner/repo/pull/56" }])
  })

  test("removes trailing punctuation from a URL", () => {
    const artifacts = collectArtifacts(
      "shell",
      { command: "gh issue create --title 'Bug'" },
      text("Created: https://github.com/owner/repo/issues/34."),
    )

    expect(artifacts).toEqual([{ kind: "issue", url: "https://github.com/owner/repo/issues/34" }])
  })

  test("deduplicates repeated URLs in one result", () => {
    const artifacts = collectArtifacts(
      "shell",
      { command: "gh pr create --fill" },
      text("https://github.com/owner/repo/pull/12\nhttps://github.com/owner/repo/pull/12"),
    )

    expect(artifacts).toEqual([{ kind: "pull-request", url: "https://github.com/owner/repo/pull/12" }])
  })

  test("finds both kinds when one command creates both", () => {
    const artifacts = collectArtifacts(
      "shell",
      { command: "gh pr create --fill && gh issue create --title 'Follow-up'" },
      text("https://github.com/owner/repo/pull/12\nhttps://github.com/owner/repo/issues/34"),
    )

    expect(artifacts).toEqual([
      { kind: "pull-request", url: "https://github.com/owner/repo/pull/12" },
      { kind: "issue", url: "https://github.com/owner/repo/issues/34" },
    ])
  })

  for (const command of [
    "printf '%s\\n' 'https://github.com/owner/repo/pull/12' # gh pr create",
    "echo 'gh pr create' && printf '%s\\n' 'https://github.com/owner/repo/pull/12'",
    'echo "x; gh pr create --fill"',
  ]) {
    test(`ignores a command that only mentions the creation command: ${command}`, () => {
      expect(collectArtifacts("shell", { command }, text("https://github.com/owner/repo/pull/12"))).toEqual([])
    })
  }

  test("accepts environment assignments and command chaining", () => {
    const artifacts = collectArtifacts(
      "shell",
      { command: "cd repo && env GH_TOKEN=token gh  pr  create --fill" },
      text("https://github.com/owner/repo/pull/12"),
    )

    expect(artifacts).toEqual([{ kind: "pull-request", url: "https://github.com/owner/repo/pull/12" }])
  })

  for (const [label, url] of [
    ["cleartext", "http://github.com/owner/repo/pull/12"],
    ["userinfo", "https://user:token@github.com/owner/repo/pull/12"],
    ["IP literal", "https://192.168.0.1/owner/repo/pull/12"],
  ] as const) {
    test(`rejects ${label} URLs`, () => {
      expect(collectArtifacts("shell", { command: "gh pr create --fill" }, text(url))).toEqual([])
    })
  }

  test("does not truncate a URL with trailing path characters", () => {
    const artifacts = collectArtifacts(
      "shell",
      { command: "gh pr create --fill" },
      text("https://github.com/owner/repo/pull/12abc"),
    )

    expect(artifacts).toEqual([])
  })

  test("ignores shell input without a command", () => {
    const artifacts = collectArtifacts(
      "shell",
      { path: "https://github.com/owner/repo/pull/12" },
      text("https://github.com/owner/repo/pull/12"),
    )

    expect(artifacts).toEqual([])
  })
})

describe("mergeArtifacts", () => {
  test("appends new artifacts and keeps the existing order", () => {
    const merged = mergeArtifacts(
      [{ kind: "pull-request", url: "https://github.com/owner/repo/pull/12" }],
      [
        { kind: "issue", url: "https://github.com/owner/repo/issues/34" },
        { kind: "pull-request", url: "https://github.com/owner/repo/pull/12" },
      ],
    )

    expect(merged).toEqual([
      { kind: "pull-request", url: "https://github.com/owner/repo/pull/12" },
      { kind: "issue", url: "https://github.com/owner/repo/issues/34" },
    ])
  })
})

describe("formatArtifacts", () => {
  test("renders a list of artifacts", () => {
    expect(
      formatArtifacts([
        { kind: "pull-request", url: "https://github.com/owner/repo/pull/12" },
        { kind: "issue", url: "https://github.com/owner/repo/issues/34" },
      ]),
    ).toBe(
      ["成果物", "- PR: https://github.com/owner/repo/pull/12", "- Issue: https://github.com/owner/repo/issues/34"].join(
        "\n",
      ),
    )
  })

  test("renders nothing for an empty list", () => {
    expect(formatArtifacts([])).toBe("")
  })
})
