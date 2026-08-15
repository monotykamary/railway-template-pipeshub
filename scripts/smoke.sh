#!/bin/sh
set -eu

: "${BASE_URL:?Set BASE_URL to the public PipesHub origin}"
base="${BASE_URL%/}"
tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT INT TERM

curl -fsS "$base/api/v1/health/services" > "$tmp/health.json"
python3 - "$tmp/health.json" <<'PY'
import json
import sys

with open(sys.argv[1], encoding="utf-8") as handle:
    body = json.load(handle)
services = body.get("services") or {}
required = ("query", "connector", "indexing", "docling", "embedding")
missing = {name: services.get(name) for name in required if services.get(name) != "healthy"}
if missing:
    raise SystemExit(f"unhealthy services: {missing}")
PY

curl -fsS "$base/" > "$tmp/home.html"
grep -qi 'PipesHub' "$tmp/home.html"
curl -fsS "$base/api/v1/org/exists" > "$tmp/org.json"
python3 - "$tmp/org.json" <<'PY'
import json
import sys

with open(sys.argv[1], encoding="utf-8") as handle:
    body = json.load(handle)
if body.get("exists") is not True:
    raise SystemExit("initial organization is missing")
PY

status="$(curl -sS -o "$tmp/private.json" -w '%{http_code}' "$base/api/v1/org/")"
case "$status" in
  401|403) ;;
  *) echo "Expected unauthenticated organization API to reject access, got HTTP $status" >&2; exit 1 ;;
esac

printf 'PipesHub smoke checks passed.\n'
