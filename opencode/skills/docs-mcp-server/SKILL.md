---
name: docs-mcp-server
description: Use when indexing, searching, or fetching documentation via the arabold/docs-mcp-server MCP server. Triggers when the user wants to scrape docs, search indexed libraries, refresh doc indexes, manage doc jobs, or configure the docs-mcp-server tool.
---

# docs-mcp-server

Package: `@arabold/docs-mcp-server`  
Requires: Node.js >= 22  
GitHub: https://github.com/arabold/docs-mcp-server  
Docker: `ghcr.io/arabold/docs-mcp-server:latest`

Indexes documentation from any URL or local file, stores it in SQLite with optional vector embeddings, and exposes it to AI clients via MCP tools.

---

## Running

**As MCP server (stdio, embedded in client):**
```json
{
  "mcpServers": {
    "docs-mcp-server": {
      "command": "npx",
      "args": ["@arabold/docs-mcp-server@latest"],
      "env": { "OPENAI_API_KEY": "sk-..." }
    }
  }
}
```

**Standalone HTTP server (includes web UI on port 6280):**
```bash
npx @arabold/docs-mcp-server@latest
# MCP endpoint: http://localhost:6280/mcp
# SSE (legacy): http://localhost:6280/sse
```

Protocol auto-detection: stdio when piped (MCP client), HTTP when run in a terminal.

---

## CLI Commands

### `scrape <library> <url>`
Index docs from a URL or `file:///path`.

| Flag | Default | Description |
|---|---|---|
| `--version`, `-v` | — | Version label |
| `--max-pages`, `-p` | 1000 | Max pages to crawl |
| `--max-depth`, `-d` | 3 | Max link depth |
| `--max-concurrency`, `-c` | 3 | Concurrent fetches |
| `--scope` | `subpages` | `subpages` \| `hostname` \| `domain` |
| `--scrape-mode` | `auto` | `auto` \| `fetch` \| `playwright` |
| `--include-pattern` | — | Glob or `/regex/` URL include filter (repeatable) |
| `--exclude-pattern` | — | Glob or `/regex/` URL exclude filter (repeatable, takes precedence) |
| `--header` | — | Custom request header `Name: Value` (repeatable) |
| `--no-clean` | — | Append instead of replacing existing docs |
| `--ignore-errors` | true | Continue on per-page errors |

```bash
npx @arabold/docs-mcp-server@latest scrape react https://react.dev/reference/react --version 18 --max-pages 500
npx @arabold/docs-mcp-server@latest scrape mylib file:///home/user/docs/
npx @arabold/docs-mcp-server@latest scrape ts https://typescriptlang.org/docs \
  --include-pattern '/docs/**' --exclude-pattern '/docs/release-notes/**'
```

### `search <library> <query>`
Query indexed docs.

| Flag | Default | Description |
|---|---|---|
| `--version`, `-v` | — | Version filter (supports X-ranges: `5.x`, `5.2.x`) |
| `--limit`, `-l` | 5 | Max results |
| `--exact-match`, `-e` | false | Require exact version match |
| `--output` | json | `json` \| `yaml` \| `toon` |

```bash
npx @arabold/docs-mcp-server@latest search react "useEffect cleanup" --version 18
npx @arabold/docs-mcp-server@latest search typescript "ReturnType" --version 5.x --limit 10
```

### `fetch-url <url>`
Fetch a single URL as Markdown (no indexing).

```bash
npx @arabold/docs-mcp-server@latest fetch-url https://react.dev/reference/react/useEffect --scrape-mode playwright
```

### Other commands

| Command | Description |
|---|---|
| `list` | List all indexed libraries and versions |
| `remove <library>` | Delete indexed docs (`--version` to target specific version) |
| `refresh <library>` | Re-scrape using ETags to skip unchanged pages |
| `find-version <library>` | Resolve best-matching stored version for a pattern |
| `config [get\|set] [key] [value]` | View or edit configuration |

---

## MCP Tools (exposed to AI clients)

| Tool | Write? | Key Parameters | Description |
|---|---|---|---|
| `search_docs` | no | `library`, `query`, `version` (X-range), `limit` | Hybrid FTS + vector search |
| `list_libraries` | no | — | All indexed library names |
| `find_version` | no | `library`, `targetVersion` | Resolve closest stored version |
| `fetch_url` | no | `url`, `followRedirects` | Fetch any URL as Markdown |
| `scrape_docs` | yes | `url`, `library`, `version`, `maxPages`, `maxDepth`, `scope` | Enqueue scrape job (async, returns `jobId`) |
| `refresh_version` | yes | `library`, `version` | Enqueue incremental refresh |
| `list_jobs` | yes | `status` | List pipeline jobs |
| `get_job_info` | yes | `jobId` | Get job details |
| `cancel_job` | yes | `jobId` | Cancel a job |
| `remove_docs` | yes | `library`, `version` | Remove indexed docs |

Write tools are hidden when `readOnly: true`.  
`scrape_docs` is **async** — use `list_jobs`/`get_job_info` to poll. The CLI `scrape` command waits synchronously.

---

## Configuration

Config file: `~/.config/docs-mcp-server/config.yaml` (Linux)  
Override with `--config /path/to/file.yaml` (makes it read-only — server won't modify it).

Priority: CLI flags > env vars > config file > defaults

Key config options:
```yaml
app:
  storePath: ~/.docs-mcp-server   # DB/data directory
  readOnly: false
  embeddingModel: text-embedding-3-small
  telemetryEnabled: true          # anonymous, disable if preferred

scraper:
  maxPages: 1000
  maxDepth: 3
  maxConcurrency: 3
  pageTimeoutMs: 5000
```

Key environment variables:

| Variable | Description |
|---|---|
| `OPENAI_API_KEY` | Enables vector embeddings (hybrid search) |
| `OPENAI_API_BASE` | Custom OpenAI-compatible endpoint (Ollama, LM Studio) |
| `DOCS_MCP_STORE_PATH` | Override data directory |
| `DOCS_MCP_CONFIG` | Path to config YAML |
| `DOCS_MCP_APP_TELEMETRY_ENABLED` | Disable telemetry (`false`) |
| `GOOGLE_API_KEY` | Gemini embeddings |
| `AWS_ACCESS_KEY_ID` / `AWS_SECRET_ACCESS_KEY` / `AWS_REGION` | Bedrock embeddings |
| `GITHUB_TOKEN` | Avoid GitHub rate limits when scraping GitHub repos |

---

## Scraping & Search Details

**Scrape modes:**
- `auto` / `playwright` — headless Chromium, handles JS-heavy SPAs. Playwright is NOT auto-installed; run `npx playwright install chromium` if needed (Docker image includes it).
- `fetch` — lightweight (cheerio/jsdom), faster, no JS execution.

**Scope:**
- `subpages` (default) — same hostname + path prefix as start URL
- `hostname` — any URL on the same hostname
- `domain` — same TLD+1, including subdomains

**Search without embeddings:** FTS only (SQLite full-text search).  
**Search with embeddings:** Hybrid FTS + vector (RRF fusion). Significantly better relevance.

**Version matching:** Fuzzy by default — finds closest indexed version ≤ requested. Supports X-ranges (`5.x`). Use `--exact-match` to require exact.

---

## Gotchas

- **Node.js 22+ required.** Run `npm rebuild` after switching Node versions (native deps: `better-sqlite3`, `sqlite-vec`, `tree-sitter`).
- **Embedding model change requires full re-scrape.** Changing models invalidates all stored vectors.
- **`--clean` is default on `scrape`.** Wipes existing docs for that library+version before indexing. Use `--no-clean` to append.
- **`refresh` requires prior index.** Uses stored scrape config + ETags. Use `scrape` for a full re-index.
- **Config file auto-updated on startup.** Use `--config` with explicit path to prevent this.
- **Telemetry on by default.** Disable with `DOCS_MCP_APP_TELEMETRY_ENABLED=false`.
- **GitHub rate limit.** 60 req/hour without token. Set `GITHUB_TOKEN` for 5000/hour.
- **PDF/Office docs capped at 10MB.** Override with `DOCS_MCP_SCRAPER_DOCUMENT_MAX_SIZE`.
