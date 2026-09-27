# Qumge MCP

**An app store for agents, over MCP.** Connect once and your agent can find and call paid
apps (billed per call from your Qumge balance), search and install curated agent skills,
see which LLMs one Qumge key reaches, and publish your own app — all in natural language.

- Endpoint: `https://qumge.com/mcp`
- Transport: Streamable HTTP (stateless — POST only, no sessions)
- Registry: [`com.qumge/skills`](https://registry.modelcontextprotocol.io/v0/servers?search=qumge)

This is a **hosted** server: there is nothing to install or run locally. This repo holds
its documentation and registry metadata; the server itself runs at qumge.com.

## Connect

Searching works without a key. For anything that spends your balance, add your key
(`sk_qumge_…`, from https://qumge.com/en/gateway/api_keys) — or leave it out and let the
agent open a login link for you to approve when it first needs one.

**Claude Code**

```bash
claude mcp add --transport http qumge https://qumge.com/mcp
# with a key:
claude mcp add --transport http qumge https://qumge.com/mcp \
  --header "Authorization: Bearer sk_qumge_…"
```

**Cursor** — `~/.cursor/mcp.json`

```json
{
  "mcpServers": {
    "qumge": {
      "url": "https://qumge.com/mcp",
      "headers": { "Authorization": "Bearer sk_qumge_…" }
    }
  }
}
```

**VS Code** — `.vscode/mcp.json`

```json
{
  "servers": {
    "qumge": {
      "type": "http",
      "url": "https://qumge.com/mcp",
      "headers": { "Authorization": "Bearer sk_qumge_…" }
    }
  }
}
```

**Claude.ai / Claude Desktop / ChatGPT connectors** — add a custom connector with the URL
`https://qumge.com/mcp`. These clients can't set headers, so paid tools sign you in with
OAuth the first time; the key it creates shows up under API Keys as "<client> via OAuth".

**Clients that can't set headers or do OAuth** — pass `qumge_key: "sk_qumge_…"` as an
argument to the paid tools.

## Tools

| Tool | Key | What it does |
|---|---|---|
| `search_apps` | – | Find paid apps by what you want done, with price, success rate and latency |
| `get_app` | – | An app's price book, routes, per-call maximum and error codes |
| `call_app` | yes | Call an app; charged to your balance at the app's own price. 5xx is free |
| `get_balance` | yes | Your balance, each app's spend against its monthly cap, and a top-up link |
| `search_skills` | – | Search a curated catalog of popular agent skills (SKILL.md) |
| `get_skill` | – | Fetch a skill's SKILL.md (and its other files) to install it |
| `list_categories` | – | Skill categories and counts |
| `list_models` | – | LLMs reachable with one Qumge key (tool-calling models only) |
| `become_developer` | yes | Open a developer account — immediate, no review |
| `list_apps` | yes | Your own apps and their status |
| `publish_app` | yes | Publish your HTTPS service as a draft app with its price book |
| `test_app` | yes | Signed/forged ping plus an end-to-end call of each route |
| `submit_app_review` | yes | Take an app live — immediately |
| `app_status` | yes | An app's review checklist and state |

## Try

- "Find me a skill that extracts tables from PDFs and install it"
- "What models can I use with my Qumge key?"
- "What's my Qumge balance?"
- "Publish my API at https://api.example.com on Qumge and take it live"

## Pricing

Pay-as-you-go: top up your balance, then pay per call (apps) or per token (models).
Apps cost the same through Qumge as calling them directly; a failed call costs nothing.
Each app has a monthly cap you control.

## See also

- [qumg-skill](https://github.com/xnjiang/qumg-skill) — the matching skill, which teaches
  an agent when and how to use these tools (and falls back to HTTP without MCP)
- https://qumge.com/llms.txt — the site index for agents
- https://qumge.com/v1/apps/openapi.json — the app catalog as OpenAPI

## License

MIT (this documentation). The hosted service is governed by qumge.com's terms.
