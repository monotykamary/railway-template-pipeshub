FROM pipeshubai/pipeshub-ai:0.9.1-slim@sha256:1776dfc71088babaf17a199e7e6c939ca3d2f014a3483f5a0b62b6e8e6e3a6b8

LABEL org.opencontainers.image.source="https://github.com/monotykamary/railway-template-pipeshub"
LABEL org.opencontainers.image.version="0.9.1-slim"

COPY --chmod=755 entrypoint.sh /usr/local/bin/railway-pipeshub-entrypoint
ENTRYPOINT ["/usr/local/bin/railway-pipeshub-entrypoint"]
