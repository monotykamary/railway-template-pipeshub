FROM redis:8.4.6@sha256:caf90da0045e7af357b1e30446ca13a07b78b502aed2979f364d344cb26b8e70

LABEL org.opencontainers.image.source="https://github.com/monotykamary/railway-template-pipeshub"

COPY --chmod=755 start.sh /usr/local/bin/start-pipeshub-redis
CMD ["/usr/local/bin/start-pipeshub-redis"]
