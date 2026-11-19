
FROM alpine:3.22

RUN apk add --no-cache \
    bash \
    tar \
    coreutils \
    findutils

ARG APP_UID=1000
ARG APP_GID=1000

RUN addgroup -g ${APP_GID} app && \
    adduser -D -u ${APP_UID} -G app app

WORKDIR /app

COPY scripts/ /app/scripts/

RUN chmod +x /app/scripts/*.sh && \
    mkdir -p /app/logs /data/source \
    /data/backups /data/restore && \
    chown -R app:app /app

USER app

ENTRYPOINT ["/bin/bash"]
