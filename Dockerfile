FROM traefik:v2.4.9

ARG BUILD_DATE

LABEL cbwx.mcbe-announce.enable=true
LABEL manymine.enable=true
LABEL org.opencontainers.image.authors="Cory Claflin"
LABEL org.opencontainers.image.created=$BUILD_DATE
LABEL org.opencontainers.image.licenses='MIT'
LABEL org.opencontainers.image.source='https://github.com/cubeworx/cbwxproxy'
LABEL org.opencontainers.image.title="CubeWorx Minecraft Proxy"
LABEL org.opencontainers.image.vendor='CubeWorx'

ENV CBWXPROXY_ADMIN_PORT=8888 \
    CBWXPROXY_BEDROCK_ENABLE="false" \
    CBWXPROXY_BEDROCK_PORT=19132 \
    CBWXPROXY_JAVA_ENABLE="false" \
    CBWXPROXY_JAVA_PORT=25565 \
    TZ="UTC"

EXPOSE $CBWXPROXY_ADMIN_PORT
EXPOSE $CBWXPROXY_BEDROCK_PORT/udp
EXPOSE $CBWXPROXY_JAVA_PORT

ADD entrypoint.sh /