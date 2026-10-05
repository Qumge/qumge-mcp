# Qumge MCP

**The capability layer for agents, over MCP.** Connect once and your agent can find and call
paid capabilities (billed per call from your Qumge balance), search and install curated agent
skills, see which LLMs one Qumge key reaches, and publish your own capability — all in
natural language.

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

Every tool returns `structuredContent` (JSON) alongside the text in `content`, and declares
an `outputSchema` in `tools/list`. **Build against `structuredContent`, the tool names and
the HTTP API** — those are the contract. The wording of the text is written for a model to
read and may change without notice.

| Tool | Key | What it does |
|---|---|---|
| `search_caps` | – | Find capabilities by what you want done, with price, success rate and latency |
| `get_cap` | – | A capability's operations, input schemas, per-call maximum and error codes |
| `call_cap` | yes | Call a capability; charged to your balance at its own price. 5xx is free |
| `get_balance` | yes | Your balance, what each capability spent against its monthly limit, and a top-up link |
| `get_earnings` | yes | Developer earnings: pending, payable, paid out, recent entries |
| `request_payout` | yes | Ask for a payout of the payable balance, with fee and tax estimate |
| `list_wanted` | – | What agents searched for and found nothing — the demand side of the store |
| `search_skills` | – | Search a curated catalog of popular agent skills (SKILL.md) |
| `get_skill` | – | Fetch a skill's SKILL.md (and its other files) to install it |
| `list_categories` | – | Skill categories and counts |
| `list_models` | – | LLMs reachable with one Qumge key (tool-calling models only) |
| `become_developer` | yes | Open a developer account — immediate, no review |
| `list_caps` | yes | Your own capabilities and their status |
| `verify_domain` | yes | Prove you own your service's domain: get the line to deploy, then check it |
| `publish_cap` | yes | Publish your HTTPS service as a draft capability with its price book |
| `test_cap` | yes | Signed/forged ping plus an end-to-end call of each operation |
| `submit_cap` | yes | Take a capability live — immediately |
| `cap_status` | yes | A capability's publishing checklist and state |

Older clients may still call the pre-rename names (`search_apps`, `get_app`, `call_app`,
`publish_app`, `test_app`, `submit_app_review`, `app_status`, `list_apps`): the server keeps
dispatching them — they are just no longer advertised here.

## Try

- "Find me a skill that extracts tables from PDFs and install it"
- "What models can I use with my Qumge key?"
- "What's my Qumge balance?"
- "Publish my API at https://api.example.com on Qumge and take it live"

## Already have a remote MCP server?

You do not have to expose a REST API. `publish_cap` takes `mcp_url` instead of `base_url`:
Qumge calls `tools/list`, and every tool you price with `mcp_tools` becomes one operation
(the tool's own description and `inputSchema` are what agents read). The domain must be one
you have verified in your profile, and unpriced tools are not published. Calls go out as
`tools/call`, billed on the HTTP status: every 2xx response is charged at your price — including
a tool result with `isError: true`. Non-2xx responses and timeouts are free, so return a non-2xx
status for failures you don't want billed.

## Pricing

Pay-as-you-go: top up your balance, then pay per call (capabilities) or per token (models).
Capabilities cost the same through Qumge as calling them directly; a failed call costs
nothing. Each capability has a monthly limit you control.

## See also

- [qumge-skill](https://github.com/Qumge/qumge-skill) — the matching skill, which teaches
  an agent when and how to use these tools (and falls back to HTTP without MCP)
- https://qumge.com/llms.txt — the site index for agents
- https://qumge.com/v1/caps/openapi.json — the capability catalogue as OpenAPI

## License

MIT (this documentation). The hosted service is governed by qumge.com's terms.
