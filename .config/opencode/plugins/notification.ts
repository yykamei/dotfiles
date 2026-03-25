import type { Plugin } from "@opencode-ai/plugin"

// Helper function to send notification with sound
const notify = async (
  $: any,
  message: string,
  sound: string = "Glass"
): Promise<void> => {
  await $`osascript -e ${"display notification \"" + message + "\" with title \"OpenCode\" sound name \"" + sound + "\""}`
}

export const NotificationPlugin: Plugin = async ({ $ }) => {
  return {
    event: async ({ event }) => {
      if (event.type === "permission.asked") {
        await notify($, "Permission required")
      }
      if (event.type === "session.idle") {
        await notify($, "Task completed - waiting for input")
      }
    },

    "tool.execute.before": async (input) => {
      if (input.tool === "question") {
        await notify($, "Question for you")
      }
    },
  }
}
