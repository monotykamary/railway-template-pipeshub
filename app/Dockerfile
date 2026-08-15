FROM pipeshubai/pipeshub-ai:0.6.0-slim@sha256:8bfc3fc47eee2968042338563f464d0853245a099c22731a5446f8b7e0325ad0

LABEL org.opencontainers.image.source="https://github.com/monotykamary/railway-template-pipeshub"
LABEL org.opencontainers.image.version="0.6.0-slim"

COPY --chmod=755 entrypoint.sh /usr/local/bin/railway-pipeshub-entrypoint
ENTRYPOINT ["/usr/local/bin/railway-pipeshub-entrypoint"]
