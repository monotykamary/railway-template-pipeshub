FROM pipeshubai/pipeshub-ai:1.0.0-slim@sha256:ed17d7fa42b4025cb5ae66767b4302f947564d9187e7fef1e025a47a007a8ddd

LABEL org.opencontainers.image.source="https://github.com/monotykamary/railway-template-pipeshub"
LABEL org.opencontainers.image.version="1.0.0-slim"

COPY --chmod=755 entrypoint.sh /usr/local/bin/railway-pipeshub-entrypoint
ENTRYPOINT ["/usr/local/bin/railway-pipeshub-entrypoint"]
