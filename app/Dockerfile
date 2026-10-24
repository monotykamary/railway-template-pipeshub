FROM pipeshubai/pipeshub-ai:0.11.1-slim@sha256:f14b4405db3e4221f1a41f163dfc1681fbe7160573bc71df8fbb53f827479c0b

LABEL org.opencontainers.image.source="https://github.com/monotykamary/railway-template-pipeshub"
LABEL org.opencontainers.image.version="0.11.1-slim"

COPY --chmod=755 entrypoint.sh /usr/local/bin/railway-pipeshub-entrypoint
ENTRYPOINT ["/usr/local/bin/railway-pipeshub-entrypoint"]
