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

## Available Agents

Subagents for specialized tasks. Located in `~/.config/opencode/agents/`:

| Agent             | Purpose                                       |
| ----------------- | --------------------------------------------- |
| security-reviewer | Security vulnerability analysis and checklist |
