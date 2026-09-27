FROM redis:8.4.7-alpine@sha256:0514fa59e3d84e2f3be66731c5401fc2a85b8ea71b49c0116c850f6a558076f4

LABEL org.opencontainers.image.source="https://github.com/monotykamary/railway-template-pipeshub"

COPY --chmod=755 start.sh /usr/local/bin/start-pipeshub-redis
CMD ["/usr/local/bin/start-pipeshub-redis"]
