FROM pipeshubai/pipeshub-ai:0.8.0-slim@sha256:b54ecd2060c5d40218c6a5b8720f2d9f269ce9b238212aa346357ebc2983ad2e

LABEL org.opencontainers.image.source="https://github.com/monotykamary/railway-template-pipeshub"
LABEL org.opencontainers.image.version="0.8.0-slim"

COPY --chmod=755 entrypoint.sh /usr/local/bin/railway-pipeshub-entrypoint
ENTRYPOINT ["/usr/local/bin/railway-pipeshub-entrypoint"]
