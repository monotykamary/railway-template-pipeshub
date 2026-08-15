#!/bin/sh
set -eu

: "${REDIS_PASSWORD:?REDIS_PASSWORD is required}"
exec redis-server \
  --appendonly yes \
  --appendfsync everysec \
  --requirepass "$REDIS_PASSWORD"
