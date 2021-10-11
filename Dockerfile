FROM traefik:v2.5.3

ARG BUILD_DATE

LABEL cbwx.announce.enable="true"
LABEL cbwx.announce.type="proxy"
LABEL org.opencontainers.image.authors="Cory Claflin"
LABEL org.opencontainers.image.created=$BUILD_DATE
LABEL org.opencontainers.image.licenses='MIT'
LABEL org.opencontainers.image.source='https://github.com/cubeworx/cbwxproxy'
LABEL org.opencontainers.image.title="CubeWorx Minecraft Server Proxy"
LABEL org.opencontainers.image.vendor='CubeWorx'

ENV CBWXPROXY_BEDROCK_ENABLE="false" \
    CBWXPROXY_BEDROCK_PORT=19132 \
    CBWXPROXY_JAVA_ENABLE="false" \
    CBWXPROXY_JAVA_PORT=25565 \
    TRAEFIK_ADMIN_PORT=8888 \
    TZ="UTC"

EXPOSE $CBWXPROXY_BEDROCK_PORT/udp
EXPOSE $CBWXPROXY_JAVA_PORT
EXPOSE $TRAEFIK_ADMIN_PORT

HEALTHCHECK --interval=30s --timeout=1s CMD curl -f http://localhost:$TRAEFIK_ADMIN_PORT/ping || exit 1

RUN set -x && \
    apk add --update --no-cache curl && \
    rm -rf /var/cache/apk/*

ADD entrypoint.sh /