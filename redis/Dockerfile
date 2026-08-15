FROM redis:8.4.0-bookworm@sha256:c22af04bb576503bf16b3e34a1fd2fd82de0f765afd866d2e380145e0af30d78

LABEL org.opencontainers.image.source="https://github.com/monotykamary/railway-template-pipeshub"

COPY --chmod=755 start.sh /usr/local/bin/start-pipeshub-redis
CMD ["/usr/local/bin/start-pipeshub-redis"]
