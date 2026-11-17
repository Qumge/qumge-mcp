# Qumge MCP

[English](README.md) | [简体中文](README.zh-CN.md)

**The hosted platform tools shared by two Qumge skills.** Agents can discover and call
complete-result capabilities, read catalog skills/model metadata, and register or manage a
developer's capabilities through https://qumge.com/mcp.

This repository contains connection documentation and registry metadata. The server runs
at qumge.com; adding this connection does not install a local runtime, inspect a developer's
filesystem or deploy their application.

- Endpoint: `https://qumge.com/mcp`
- Transport: Streamable HTTP, stateless POST
- Registry: `com.qumge/skills` (retained for existing clients)

## Skills and responsibilities

| Entry | Audience | Responsibility |
|---|---|---|
| **qumge** | Buyers/model users | Find and use Caps, install catalog skills, connect model clients and check spending balance. |
| **qumge-publish** | Developers | Use the coding Agent's local tools to inspect/adapt/test/deploy a project, then call this MCP to register, validate, publish and manage its Cap. |
| **Qumge MCP** | Both | Operate the hosted platform. The same endpoint/account works with either skill. |

Both skills live in [Qumge/qumge-skill](https://github.com/Qumge/qumge-skill). The original
consumer installation is unchanged. Install the self-contained publisher with:

```bash
npx skills add Qumge/qumge-skill --full-depth --skill qumge-publish
```

Full-depth discovery is necessary when the root SKILL.md would otherwise hide nested skills.
The publisher includes offline preflight and HTTP/auth fallback; the consumer skill is optional.
There is no second MCP server, repository or automatic cloud hosting of arbitrary CLIs.

## Connect

Searching works without a key. Account tools need your key, including free quotes, job reads
and balance checks as well as spending. Add your key
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
`https://qumge.com/mcp`. These clients can't set headers, so authenticated tools sign you in with
OAuth the first time; the key it creates shows up under API Keys as "<client> via OAuth".

**Clients that can't set headers or do OAuth** — pass `qumge_key: "sk_qumge_…"` as an
argument to authenticated tools.

## Tools

Every tool advertises its current input/output schemas through tools/list. Prefer
structuredContent (JSON); content text is display copy. Handle protocol error and result.isError.
The complete maintained reference is https://qumge.com/en/docs/mcp.

| Tool | Key | What it does |
|---|---|---|
| `search_caps` | – | Find complete-result capabilities by task and published price |
| `get_cap` | optional | Read effective/pending contracts, operations, limits and current confirmation requirements |
| `quote_cap` | yes | Free binding quote for complete metered input; supports capped_actual limits and an optional budget |
| `call_cap` | yes | Invoke an operation; metered calls require quote_id and stable idempotency_key; accept changed contracts when required |
| `get_cap_job` | yes | Free cached job progress, result and receipt; explicit refresh_result for supported URL renewal |
| `get_balance` | yes | Spending balance, monthly limits and top-up link |
| `search_skills` | – | Search the curated skill catalog |
| `get_skill` | – | Read SKILL.md and optional supporting files for the Agent to install |
| `list_categories` | – | Skill categories and counts |
| `list_models` | – | Discover reachable tool-calling models; inference uses the compatible model API |
| `list_wanted` | – | Public capability-demand evidence |
| `become_developer` | yes | Open the owner's developer account |
| `list_caps` | yes | Read the owner's capability states |
| `verify_domain` | yes | Verify the service domain before releasing frozen developer earnings |
| `publish_cap` | yes | Create/update a draft from a deployed manifest; does not deploy or take it live |
| `test_cap` | yes | Validate the applicable connection/fixture contract, with exact candidate price_version when requested |
| `submit_cap` | yes | Make a tested draft live within the owner's publication scope |
| `cap_status` | yes | Read the publishing checklist and effective/pending state |
| `migrate_cap_contract` | yes | Owner-scoped prepare/test/activate/status/repair_review for existing contracts; inspect its current schema |
| `delist_cap` | yes | Stop new calls immediately; preserve the public page marked delisted |
| `relist_cap` | yes | Restore a delisted Cap; changed addresses are retested |
| `get_earnings` | yes | Developer pending/payable/paid earnings |
| `request_payout` | yes | Request payout of Cap income within the owner's authority |

Pre-rename aliases still dispatch for existing clients, including search_apps/get_app/call_app,
publish_app/test_app/submit_app_review/app_status/list_apps. New clients use Cap names.

## Publishing: the current default

Use a managed **manifest v2** describing one clear input and one complete usable result:
https://qumge.com/schemas/qumge-manifest/v2.json. Keep provider credentials in a private
named connection; they never belong in public JSON. Serve the actual manifest over HTTPS,
then call publish_cap(manifest_url:, slug:). A suggested manifest price is not owner approval.

The publisher Agent implements and deploys only the missing provider hooks using the
project's existing framework, jobs, workers and private storage. Qumge supplies discovery,
invocation, buyer orders and settlement, not the provider's business execution environment.

Run local checks, then test_cap, distinguish connection/fixture/real_delivery and read the
version tested. Fixtures do not establish business quality or real paid delivery. Call
submit_cap only within existing owner publication scope; do not ask again for an approval
already given. If the price/publication scope is missing, present the ready draft and ask
only for that decision. Read back the actual live/effective state afterward.

Domain verification is required to release earnings, not merely to list a Cap. A domain
verified by another developer cannot be claimed. Keys, paid real tests, deployment and
publication are separate authorization scopes.

### Existing API or remote MCP

A complete-result API/MCP operation can be reused with supported managed execution mapping.
If several partial operations are needed, compose them privately on the provider server.
For a CLI/internal function, add thin HTTPS hooks and choose a real deployment environment.

Advanced legacy manual HTTP price books and mcp_url/mcp_tools registration remain supported
for existing integrations. Read tools/list and current docs rather than copying old v1
examples into a new managed integration. For native MCP failures, isError/JSON-RPC tool
errors are not a successful billed result. Managed settlement requires the complete successful
result and output schema, not merely a 2xx or an accepted/queued job ID.

## Calling and paying

The buyer uses the current get_cap deliverable, price and spending authority. If
contract_state.confirmation_required is true, confirm that changed result before passing
its current contract_digest as accepted_contract_digest. Old permission is not acceptance
of a different deliverable. For retrying the same managed operation/input, reuse the same
idempotency_key; poll the returned platform job ID instead of creating another generation.

For a metered operation (`quote_required: true`), call `quote_cap` with its `slug`,
`operation` and complete `input` before spending. It requires the buyer's key but is free:
no provider work, fund reservation, charge or free-call consumption. For `capped_actual`,
include `limits` for every output-metered line (positive maximum quantities within the Cap's
limits). Optional `max_charge_micro_usd` rejects a quote above your budget. Read
`amount_micro_usd`, `kind` (`exact` or `ceiling`), `resolved_dimensions` and `expires_at`,
then confirm the amount within the user's spending authority. One USD is 1,000,000 micro-USD.

Pass the returned `quote_id` to `call_cap` with the identical input and a saved stable
`idempotency_key`. The quote is bound to the buyer, Cap, operation and input for 10 minutes;
one quote can create only one order. The order reserves the quoted amount; its final job
receipt records the settled charge. Fixed-price and legacy calls keep their existing flow
and do not universally require a quote.

If a call's outcome is uncertain, read its `get_cap_job` for free, or replay the original
call with the same quote, input and key to recover the original order, even after expiry.
Do this before requesting a replacement quote. If no order was created and the unused quote
returns `quote_expired` or `quote_contract_changed`, re-read `get_cap`, obtain a fresh quote
and check the current amount/authority before calling. `quote_already_used` is a reason to
recover the original order, not to switch keys. Never start a duplicate generation.

Qumge is pay-as-you-go: buyers top up first, then pay per complete managed result or model
usage. Some Caps offer free calls to previously topped-up users; a successful call consumes
a free call. Availability/price/free-call limits come from the current catalog and contract,
not the README. Do not promise free trial credits or lower-than-direct provider pricing.
A 402 means balance/monthly limit; resolve it rather than retrying.

## Sources

- Skills: https://github.com/Qumge/qumge-skill
- Current managed contract: https://qumge.com/en/docs/caps/managed
- Manifest: https://qumge.com/en/docs/caps/manifest
- Agent index: https://qumge.com/llms.txt
- OpenAPI catalog: https://qumge.com/v1/caps/openapi.json

## Maintenance checks

Run `bash scripts/check-tools.sh` for metadata-only `tools/list` verification of both
language tables, metered argument schemas and flow guidance. For offline checks, set
`QUMGE_TOOLS_FILE` to a previously captured tools/list JSON response. No paid tool is invoked.

## License

MIT (this documentation). The hosted service is governed by qumge.com's terms.
