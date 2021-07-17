FROM traefik:v2.4.9

ARG BUILD_DATE

LABEL cbwx.mcbe-announce.enable=true
LABEL manymine.enable=true
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

ADD entrypoint.sh /

HEALTHCHECK --interval=60s --timeout=1s CMD curl -f http://localhost:$TRAEFIK_ADMIN_PORT/ping || exit 1

RUN set -x && \
    apk add --update --no-cache curl && \
    rm -rf /var/cache/apk/*