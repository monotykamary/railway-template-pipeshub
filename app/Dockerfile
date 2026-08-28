FROM pipeshubai/pipeshub-ai:0.7.0-slim@sha256:400358686a0794305a96bfb6d0f502b85f20fc0cb16a838d90c74bfa3e8dfb91

LABEL org.opencontainers.image.source="https://github.com/monotykamary/railway-template-pipeshub"
LABEL org.opencontainers.image.version="0.7.0-slim"

COPY --chmod=755 entrypoint.sh /usr/local/bin/railway-pipeshub-entrypoint
ENTRYPOINT ["/usr/local/bin/railway-pipeshub-entrypoint"]
