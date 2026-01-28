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
    // permission.asked event - when permission is required
    event: async ({ event }) => {
      if (event.type === "permission.asked") {
        await notify($, "Permission required")
      }
    },

    // Before tool execution - notify when question is about to be shown
    "tool.execute.before": async (input) => {
      // question tool - asking user a question
      if (input.tool === "question") {
        await notify($, "Question for you")
      }
    },

    // When message is complete and assistant is waiting for input
    "message.complete": async (message) => {
      // Notify user that OpenCode is ready for their response
      await notify($, "Ready for your response")
    },
  }
}
