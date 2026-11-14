import { Plugin } from "@opencode/plugin"
import { collectArtifacts } from "./artifacts"
import { createPublisher } from "./publisher"

const MAX_PARENT_DEPTH = 32
const MAX_CACHED_SESSIONS = 1000

const errorMessage = (error: unknown) =>
  String(error instanceof Error ? error.message : error).replace(/[\r\n]+/g, " ")

/**
 * Shows the PR and issue links created during a session at the end of each
 * turn. OpenCode loads this plugin from the global plugin directory; it records
 * the URLs printed by `gh pr create` and `gh issue create`, waits for the root
 * session to become idle, and appends a cumulative note (up to 50 artifacts).
 * The note never starts another model turn.
 *
 * Usage: save under `~/.config/opencode/plugins/session-artifacts/`. A
 * `gh pr create` run then adds:
 *
 * ```text
 * 成果物
 * - PR: https://github.com/owner/repo/pull/12
 * ```
 */
export default Plugin.define({
  id: "session-artifacts",
  async setup(ctx) {
    const rootCache = new Map<string, string>()

    const rootOf = async (sessionID: string): Promise<string> => {
      const cached = rootCache.get(sessionID)
      if (cached !== undefined) return cached

      const chain: string[] = []
      const seen = new Set<string>()
      let current = sessionID
      let root = sessionID
      for (let depth = 0; depth < MAX_PARENT_DEPTH; depth++) {
        const known = rootCache.get(current)
        if (known !== undefined) {
          root = known
          break
        }
        if (seen.has(current)) {
          root = sessionID
          break
        }
        seen.add(current)
        chain.push(current)
        const info = await ctx.session.get({ sessionID: current })
        if (info.parentID === undefined) {
          root = current
          break
        }
        current = info.parentID
      }
      if (rootCache.size > MAX_CACHED_SESSIONS) rootCache.clear()
      for (const id of chain) rootCache.set(id, root)
      return root
    }

    const publisher = createPublisher({
      waitForIdle: async (root) => {
        await ctx.session.wait({ sessionID: root })
      },
      post: async (root, text) => {
        await ctx.session.synthetic({
          sessionID: root,
          text,
          description: text,
          metadata: { source: "session-artifacts" },
          // Keep the note out of the model loop: record it without scheduling a reply.
          resume: false,
        })
      },
      onError: (error) => {
        console.warn("session-artifacts: failed to publish artifacts", { error: errorMessage(error) })
      },
    })

    await ctx.tool.hook("execute.after", async (event) => {
      if (event.status !== "completed") return
      const artifacts = collectArtifacts(event.tool, event.input, event.result)
      if (artifacts.length === 0) return
      try {
        const root = await rootOf(event.sessionID)
        publisher.add(root, artifacts)
      } catch (error) {
        console.warn("session-artifacts: failed to track artifacts", {
          sessionID: event.sessionID,
          error: errorMessage(error),
        })
      }
    })

    return () => publisher.dispose()
  },
})
