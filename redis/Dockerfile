FROM redis:8.10.2-alpine@sha256:0bf6577d7774e592b29d093e3ac9390eb91e13d72c21e506afce736de5e0eeb0

LABEL org.opencontainers.image.source="https://github.com/monotykamary/railway-template-pipeshub"

COPY --chmod=755 start.sh /usr/local/bin/start-pipeshub-redis
CMD ["/usr/local/bin/start-pipeshub-redis"]
