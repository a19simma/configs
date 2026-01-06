# Claude Code Configuration

User-scoped configuration for Claude Code CLI, managed with GNU Stow.

## Installation

```bash
# Deploy settings and agents
stow claude

# Setup MCP servers (requires Docker and Node.js)
just setup-claude-mcp
```

This will symlink `~/.claude/settings.json` and `~/.claude/agents/` to your home directory, then configure Terraform and Kubernetes MCP servers via `claude mcp add`.

## What's Included

### Settings (`~/.claude/settings.json`)
- Global permissions configuration
- Web access enabled by default

### Custom Agents (`~/.claude/agents/`)

#### Researcher Agent (Haiku)
A read-only research agent specialized in:
- Codebase exploration and analysis
- Web research and documentation lookup
- Information gathering without file modifications

**Tools**: `Read, Grep, Glob, WebSearch, WebFetch` (no write access)

#### Infrastructure Agent (Sonnet)
IaC agent for Kubernetes, Helm, ArgoCD, Crossplane, Terraform, and Terragrunt:
- **Inspects Helm templates** with `helm pull --untar` before any edits
- **Renders manifests** before/after changes to see exact differences
- **Validates via kubectl explain** for ArgoCD/Crossplane CRD schemas
- **Queries Terraform MCP** for provider schemas and documentation
- **Never modifies clusters** - read-only kubectl access only
- Prevents hallucination by inspecting actual template files and schemas

**Tools**: `Read, Write, Edit, Grep, Glob, Bash, WebSearch, WebFetch` + MCP tools

**Example**: Editing a Helm values file triggers automatic template inspection, rendering with current/new values, and diff comparison of resulting manifests.

**Invoke**: Claude will automatically use these agents when appropriate, or you can explicitly reference them.

### MCP Servers (Model Context Protocol)

Configured via `just setup-claude-mcp`:

#### Terraform MCP Server (HashiCorp Official)
- Real-time Terraform Registry data access
- Provider schemas and resource definitions
- Module metadata and documentation
- **Transport**: Docker (hashicorp/terraform-mcp-server)

#### Kubernetes MCP Server (Red Hat/containers)
- Native Kubernetes API interaction (read-only mode)
- Helm operations: install/list/uninstall charts
- Resource management and pod operations
- **Transport**: npx (kubernetes-mcp-server@latest)

MCP servers are installed user-scoped and available across all projects.

### Slash Commands (`~/.claude/commands/`)

#### `/tutor`
Read-only tutoring mode for explanations and documentation:
- Provides concise explanations with code examples
- Uses context7 for library documentation
- Cites sources (file:line or URLs)
- Never modifies files (read-only)
- Brief and direct responses

**Usage**: `/tutor <your question>`

#### `/tutor-plan`
Generate a progressive learning plan for any topic or library:
- Starts with concept overview and setup instructions
- Creates checkable task lists (Foundation → Practice → Further Reading)
- Includes documentation links and brief explanations
- Gradually reduces specificity to encourage independent learning
- Prompts to continue with advanced topics after completing basics

**Usage**: `/tutor-plan gRPC setup in Rust` or `/tutor-plan learning tokio`

## Creating Custom Agents

Add new agents to `.claude/agents/` using this format:

```markdown
---
name: agent-name
description: When this agent should be invoked
tools: Read, Write, Bash
model: sonnet
---

# Agent prompt goes here
```

See the [researcher agent](/.claude/agents/researcher.md) for a complete example.

## Resources

- [Claude Code Documentation](https://docs.claude.com/en/docs/claude-code/)
- [Custom Agents Guide](https://claudelog.com/mechanics/custom-agents/)
