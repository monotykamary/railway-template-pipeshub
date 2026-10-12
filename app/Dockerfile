FROM pipeshubai/pipeshub-ai:0.10.0-slim@sha256:201bbad43229aad63e9666e43f07aca68b34cbc07a03c6be195609b8fa8d0675

LABEL org.opencontainers.image.source="https://github.com/monotykamary/railway-template-pipeshub"
LABEL org.opencontainers.image.version="0.10.0-slim"

COPY --chmod=755 entrypoint.sh /usr/local/bin/railway-pipeshub-entrypoint
ENTRYPOINT ["/usr/local/bin/railway-pipeshub-entrypoint"]
