#!/usr/bin/env bash
# Compare maintained tool tables and quote arguments with public tools/list metadata.
# QUMGE_TOOLS_FILE permits offline verification of a previously captured response.
# This script never calls tools/call.
set -euo pipefail

root="$(cd "$(dirname "$0")/.." && pwd)"
endpoint="${QUMGE_MCP_URL:-https://qumge.com/mcp}"
metadata_source="$endpoint"
if [ -n "${QUMGE_TOOLS_FILE:-}" ]; then
  snapshot="$QUMGE_TOOLS_FILE"
  metadata_source="$snapshot"
else
  snapshot="$(mktemp)"
  trap 'rm -f "$snapshot"' EXIT
  curl --connect-timeout 10 --max-time 30 -sf -X POST "$endpoint" \
    -H 'Content-Type: application/json' \
    -H 'Accept: application/json, text/event-stream' \
    -d '{"jsonrpc":"2.0","id":1,"method":"tools/list"}' -o "$snapshot"
fi

live="$(jq -r '.result.tools[].name' "$snapshot" | sort)"
if [ -z "$live" ]; then
  echo "Could not read tools/list from $endpoint" >&2
  exit 1
fi

for relative in README.md README.zh-CN.md; do
  documented="$(grep -oE '^\| `[a-z_]+` \|' "$root/$relative" | tr -d '|` ' | sort)"
  if [ "$live" != "$documented" ]; then
    echo "Tool list drifted from $relative" >&2
    diff <(echo "$documented") <(echo "$live") --label documented --label live >&2 || true
    exit 1
  fi
done

# These fields are used by the documented metered flow, beyond mere tool-name parity.
jq -e '
  (.result.tools | map({key: .name, value: .inputSchema}) | from_entries) as $schemas |
  (.result.tools[] | select(.name == "quote_cap") | .outputSchema.properties) as $quote_output |
  ($quote_output | has("quote_id") and has("amount_micro_usd") and has("kind") and has("expires_at")) and
  ($schemas.quote_cap.required | sort) == (["slug", "operation", "input"] | sort) and
  ($schemas.quote_cap.properties | has("limits") and has("max_charge_micro_usd")) and
  ($schemas.call_cap.properties | has("quote_id") and has("idempotency_key")) and
  ($schemas.get_cap_job.properties | has("job_id"))
' "$snapshot" >/dev/null || {
  echo "Metered quote/call/job schema drifted; recheck the documented flow" >&2
  exit 1
}

# Both languages must describe the quote-to-order and recovery path.
for relative in README.md README.zh-CN.md; do
  for term in quote_cap quote_id idempotency_key capped_actual max_charge_micro_usd quote_expired quote_contract_changed quote_already_used get_cap_job; do
    grep -Fq "$term" "$root/$relative" || {
      echo "Missing metered flow term $term in $relative" >&2
      exit 1
    }
  done
done

echo "OK: $(echo "$live" | wc -l | tr -d ' ') tool names and metered argument schemas match $metadata_source"
