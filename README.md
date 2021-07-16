CubeWorx Minecraft Server Proxy Image
==============

This image is a self-contained Minecraft server proxy untilizing Traefik. The image can be used to proxy a remote Bedrock Edition and/or Java Edition server on your local network. For Bedrock Edition this enables the remote server to appear under LAN Games.

## Quickstart

```
docker run -d -it -p 19132:19132/udp -e CBWXPROXY_BEDROCK_ENABLE=true -e CBWXPROXY_BEDROCK_REMOTE_HOST=<fqdn or ip>:port cubeworx/cbwxproxy
```
or
```
docker run -d -it -p 25565:25565 -e CBWXPROXY_JAVA_ENABLE=true -e CBWXPROXY_JAVA_REMOTE_HOST=<fqdn or ip>:port cubeworx/cbwxproxy
```

## Configuration

The image runs with default or recommended configurations but can be highly customized through environment variables. Changing any of the environment variables from their defaults will update the server.properties file as described here: https://minecraft.fandom.com/wiki/Server.properties#Bedrock_Edition_3


### Customized Default Configuration

|                               |                                                                         |
|-------------------------------|-------------------------------------------------------------------------|
| `CBWXPROXY_ADMIN_ENABLE="false"`  |  |
| `CBWXPROXY_ADMIN_PORT="8888"` |         |
| `CBWXPROXY_BEDROCK_ENABLE="falsel"`  |  |
| `CBWXPROXY_BEDROCK_PORT="19132"` |         |
| `CBWXPROXY_BEDROCK_REMOTE_HOST=""`  |  |
| `CBWXPROXY_DEBUG="false"` |         |
| `CBWXPROXY_JAVA_ENABLE="false"`  |  |
| `CBWXPROXY_JAVA_PORT="25565"` |         |
| `CBWXPROXY_JAVA_REMOTE_HOST=""`  |  |
| `CBWXPROXY_LOG_LEVEL="ERROR"` |         |
