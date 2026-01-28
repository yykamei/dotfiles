import type { Plugin } from "@opencode-ai/plugin"

export const NotificationPlugin: Plugin = async ({ $ }) => {
  return {
    // permission.asked event - when permission is required
    event: async ({ event }) => {
      if (event.type === "permission.asked") {
        await $`osascript -e 'display notification "Permission required" with title "OpenCode"'`
      }
    },

    // After question tool execution
    "tool.execute.after": async (input, output) => {
      if (input.tool === "question") {
        await $`osascript -e 'display notification "Question for you" with title "OpenCode"'`
      }
    },
  }
}
