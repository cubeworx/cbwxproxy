#!/usr/bin/env sh

CBWXPROXY_ADMIN_ENABLE=${CBWXPROXY_ADMIN_ENABLE:-"false"}
CBWXPROXY_ADMIN_PORT=${CBWXPROXY_ADMIN_PORT:-"8888"}
CBWXPROXY_BEDROCK_ENABLE=${CBWXPROXY_BEDROCK_ENABLE:-"false"}
CBWXPROXY_BEDROCK_PORT=${CBWXPROXY_BEDROCK_PORT:-"19132"}
CBWXPROXY_BEDROCK_REMOTE_HOST=${CBWXPROXY_BEDROCK_REMOTE_HOST:-""}
CBWXPROXY_DEBUG=${CBWXPROXY_DEBUG:="false"}
CBWXPROXY_JAVA_ENABLE=${CBWXPROXY_JAVA_ENABLE:-"false"}
CBWXPROXY_JAVA_PORT=${CBWXPROXY_JAVA_PORT:-"25565"}
CBWXPROXY_JAVA_REMOTE_HOST=${CBWXPROXY_JAVA_REMOTE_HOST:-""}
CBWXPROXY_LOG_LEVEL=${CBWXPROXY_LOG_LEVEL:-"ERROR"}

CBWXPROXY_ENTRYPOINTS_OPTS="\
entryPoints:
"

config_admin() {
  if [[ "x${CBWXPROXY_ADMIN_ENABLE}" == "xtrue" ]]; then
    if [[ "x${CBWXPROXY_ADMIN_PORT}" != "x" ]]; then
      if [[ "${CBWXPROXY_ADMIN_PORT}" -lt 1 ]] && [[ "${CBWXPROXY_ADMIN_PORT}" -gt 65535 ]]; then
        echo "ERROR: CBWXPROXY_ADMIN_PORT must be a number between 1-65535!"
        exit 1
      fi
    fi
CBWXPROXY_ENTRYPOINTS_ADMIN="\
  traefik:
    address: \":${CBWXPROXY_ADMIN_PORT}\"
"
CBWXPROXY_ADMIN_OPTS="\
api:
  dashboard: true
  debug: ${CBWXPROXY_DEBUG}
  insecure: true
ping:
  entryPoint: \"traefik\"
"
  fi
}

config_bedrock() {
  if [[ "x${CBWXPROXY_BEDROCK_ENABLE}" == "xtrue" ]]; then
    if [[ "x${CBWXPROXY_BEDROCK_REMOTE_HOST}" == "x" ]]; then
      echo "ERROR: CBWXPROXY_BEDROCK_ENABLE variable is 'true' but CBWXPROXY_BEDROCK_REMOTE_HOST variable is empty!"
      exit 1
    elif [[ "x${CBWXPROXY_BEDROCK_PORT}" != "x" ]]; then
      if [[ "${CBWXPROXY_BEDROCK_PORT}" -lt 1 ]] && [[ "${CBWXPROXY_BEDROCK_PORT}" -gt 65535 ]]; then
        echo "ERROR: CBWXPROXY_BEDROCK_PORT must be a number between 1-65535!"
        exit 1
      fi
    fi
CBWXPROXY_ENTRYPOINTS_BEDROCK="\
  bedrock:
    address: \":${CBWXPROXY_BEDROCK_PORT}/udp\"
"
CBWXPROXY_BEDROCK_OPTS="\
udp:
  routers:
    bedrock:
      service: \"bedrock\"
  services:
    bedrock:
      loadBalancer:
        servers:
        -  address: \"${CBWXPROXY_BEDROCK_REMOTE_HOST}\"
"
  fi
}

config_java() {
  if [[ "x${CBWXPROXY_JAVA_ENABLE}" == "xtrue" ]]; then
    if [[ "x${CBWXPROXY_JAVA_REMOTE_HOST}" == "x" ]]; then
      echo "ERROR: CBWXPROXY_JAVA_ENABLE variable is 'true' but CBWXPROXY_JAVA_REMOTE_HOST variable is empty!"
      exit 1
    elif [[ "x${CBWXPROXY_JAVA_PORT}" != "x" ]]; then
      if [[ "${CBWXPROXY_JAVA_PORT}" -lt 1 ]] && [[ "${CBWXPROXY_JAVA_PORT}" -gt 65535 ]]; then
        echo "ERROR: CBWXPROXY_JAVA_PORT must be a number between 1-65535!"
        exit 1
      fi
    fi
CBWXPROXY_ENTRYPOINTS_JAVA="\
  java:
    address: \":${CBWXPROXY_JAVA_PORT}\"
"
CBWXPROXY_JAVA_OPTS="\
tcp:
  routers:
    java:
      rule: \"HostSNI(`*`)\"
      service: \"java\"
  services:
    java:
      loadBalancer:
        servers:
        -  address: \"${CBWXPROXY_JAVA_REMOTE_HOST}\"
"
  fi
}

write_config() {
  CBWXPROXY_ENTRYPOINTS_OPTS=${CBWXPROXY_ENTRYPOINTS_OPTS}${CBWXPROXY_ENTRYPOINTS_ADMIN}${CBWXPROXY_ENTRYPOINTS_BEDROCK}${CBWXPROXY_ENTRYPOINTS_JAVA}
cat << EOF > /etc/traefik.yaml
# traefik.yaml
global:
  checkNewVersion: false
  sendAnonymousUsage: false
log:
  level: "${CBWXPROXY_LOG_LEVEL}"
accessLog: {}
providers:
  file:
    filename: /etc/provider.yaml
${CBWXPROXY_ADMIN_OPTS}
${CBWXPROXY_ENTRYPOINTS_OPTS}
EOF
cat << EOF > /etc/provider.yaml
${CBWXPROXY_BEDROCK_OPTS}
${CBWXPROXY_JAVA_OPTS}
EOF
}

#Check enabled
if [[ "x${CBWXPROXY_BEDROCK_ENABLE}" != "xtrue" ]] && [[ "x${CBWXPROXY_JAVA_ENABLE}" != "xtrue" ]]; then
  echo "ERROR: Either CBWXPROXY_BEDROCK_ENABLE or CBWXPROXY_JAVA_ENABLE variable must be TRUE!"
  exit 1
fi
#Check admin
config_admin
#Check bedrock
config_bedrock
#Check java
config_java
#Write config file
write_config

exec traefik --configFile=/etc/traefik.yaml