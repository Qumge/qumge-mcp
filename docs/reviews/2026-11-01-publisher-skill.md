# Shared MCP documentation alignment

The same hosted https://qumge.com/mcp serves qumge (consumer) and qumge-publish (developer).
Only documentation and its metadata drift-check invocation changed; no server/registry version,
transport, tool, account, provider runtime or production setting changed here.

README now describes managed manifest v2 as the new-integration default, the developer Agent's
local code/deployment role, draft/test/submit boundaries, effective/pending contracts, stable
managed idempotency, and the current free failure semantics for native MCP tool errors.
Advanced/legacy manual integrations remain supported but are not the default template.

Metadata-only live check passed: README lists the same 22 tools as tools/list. The corresponding
skill repository passed offline tests, actual isolated copy installs, package checks and an
independent code/package review. No paid call or Cap publication was used for validation.

Publisher installation explicitly uses --full-depth because the skill repo retains its original
root SKILL.md; the direct publisher-folder URL is an alternative. The consumer name is unchanged.
