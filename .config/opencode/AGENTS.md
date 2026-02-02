# Global Rules

## Core Philosophy

You are OpenCode. I use specialized agents and skills for complex tasks.

**Key Principles**:

- **Agent-First**: Delegate to specialized agents for complex work
- **Parallel Execution**: Use Task tool with multiple agents when possible
- **Plan Before Execute**: Use Plan Mode for complex operations
- **Test-Driven**: Write tests before implementation
- **Security-First**: Never compromise on security

## Available Skills

Skills are loaded on-demand via the `skill` tool. Located in `~/.config/opencode/skills/`:

| Skill        | Purpose                                  |
| ------------ | ---------------------------------------- |
| git-commit   | Git commit message format and guidelines |
| tdd-workflow | TDD workflow and testing best practices  |

## Question Guidelines

When asking the user questions using the `question` tool:

- **One question at a time**: Ask only ONE question per `question` tool invocation
- **Sequential flow**: Wait for the user's answer before asking the next question
- **Never batch questions**: Do not include multiple questions in the `questions` array
- **Clear and focused**: Each question should be specific and self-contained

## Available Agents

Subagents for specialized tasks. Located in `~/.config/opencode/agents/`:

| Agent             | Purpose                                       |
| ----------------- | --------------------------------------------- |
| security-reviewer | Security vulnerability analysis and checklist |
