#!/usr/bin/env bash
set -euo pipefail

if [[ $# -eq 0 ]]; then
  set -- /app/process_monitor.sh
fi

port="${PORT:-3000}"
data_dir="${PIPESHUB_DATA_DIR:-/data/pipeshub}"
marker="$data_dir/.railway-bootstrap-complete"
payload="$(mktemp)"
response="$(mktemp)"
child_pid=""

cleanup_files() {
  rm -f "$payload" "$response"
}

forward_signal() {
  if [[ -n "$child_pid" ]] && kill -0 "$child_pid" 2>/dev/null; then
    kill -TERM "$child_pid" 2>/dev/null || true
    wait "$child_pid" || true
  fi
  cleanup_files
  exit 143
}

trap cleanup_files EXIT
trap forward_signal TERM INT

mkdir -p "$data_dir"
env \
  -u PIPESHUB_ADMIN_EMAIL \
  -u PIPESHUB_ADMIN_PASSWORD \
  -u PIPESHUB_ADMIN_NAME \
  -u PIPESHUB_ORG_NAME \
  "$@" &
child_pid=$!

deadline=$((SECONDS + ${PIPESHUB_BOOTSTRAP_TIMEOUT:-300}))
org_exists=""
while (( SECONDS < deadline )); do
  if ! kill -0 "$child_pid" 2>/dev/null; then
    wait "$child_pid"
    exit $?
  fi

  if org_exists="$(curl -fsS "http://127.0.0.1:${port}/api/v1/org/exists" 2>/dev/null | python3 -c 'import json,sys; print("true" if json.load(sys.stdin).get("exists") else "false")' 2>/dev/null)"; then
    break
  fi
  sleep 2
done

if [[ "$org_exists" != "true" && "$org_exists" != "false" ]]; then
  echo "PipesHub organization bootstrap timed out." >&2
  kill -TERM "$child_pid" 2>/dev/null || true
  wait "$child_pid" || true
  exit 1
fi

if [[ "$org_exists" == "true" ]]; then
  if [[ ! -f "$marker" ]]; then
    echo "PipesHub already has an organization, but the Railway bootstrap marker is missing; refusing to assume ownership." >&2
    kill -TERM "$child_pid" 2>/dev/null || true
    wait "$child_pid" || true
    exit 1
  fi
else
  if [[ -f "$marker" ]]; then
    echo "The PipesHub bootstrap marker exists, but MongoDB has no organization; refusing to expose an inconsistent deployment." >&2
    kill -TERM "$child_pid" 2>/dev/null || true
    wait "$child_pid" || true
    exit 1
  fi

  : "${PIPESHUB_ADMIN_EMAIL:?PIPESHUB_ADMIN_EMAIL is required for the first deployment}"
  : "${PIPESHUB_ADMIN_PASSWORD:?PIPESHUB_ADMIN_PASSWORD is required for the first deployment}"
  : "${PIPESHUB_ADMIN_NAME:=Railway Admin}"
  : "${PIPESHUB_ORG_NAME:=PipesHub}"

  python3 -c 'import json,os,sys; json.dump({"accountType":"business","contactEmail":os.environ["PIPESHUB_ADMIN_EMAIL"],"registeredName":os.environ["PIPESHUB_ORG_NAME"],"adminFullName":os.environ["PIPESHUB_ADMIN_NAME"],"password":os.environ["PIPESHUB_ADMIN_PASSWORD"],"sendEmail":False},sys.stdout)' > "$payload"

  status="$(curl -sS -o "$response" -w '%{http_code}' \
    -H 'Content-Type: application/json' \
    --data-binary "@$payload" \
    "http://127.0.0.1:${port}/api/v1/org/")"
  if [[ "$status" -lt 200 || "$status" -ge 300 ]]; then
    echo "PipesHub organization bootstrap failed with HTTP ${status}." >&2
    kill -TERM "$child_pid" 2>/dev/null || true
    wait "$child_pid" || true
    exit 1
  fi

  install -m 600 /dev/null "$marker"
  echo "Initial PipesHub organization and administrator created."
fi

wait "$child_pid"
