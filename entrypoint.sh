#!/bin/sh
set -e

CBWXPROXY_BEDROCK_ENABLE=${CBWXPROXY_BEDROCK_ENABLE:-"false"}
CBWXPROXY_BEDROCK_PORT=${CBWXPROXY_BEDROCK_PORT:-"19132"}
CBWXPROXY_BEDROCK_REMOTE_HOST=${CBWXPROXY_BEDROCK_REMOTE_HOST:-""}
CBWXPROXY_JAVA_ENABLE=${CBWXPROXY_JAVA_ENABLE:-"false"}
CBWXPROXY_JAVA_PORT=${CBWXPROXY_JAVA_PORT:-"25565"}
CBWXPROXY_JAVA_REMOTE_HOST=${CBWXPROXY_JAVA_REMOTE_HOST:-""}
TRAEFIK_ADMIN_DEBUG=${TRAEFIK_ADMIN_DEBUG:="false"}
TRAEFIK_ADMIN_ENABLE=${TRAEFIK_ADMIN_ENABLE:-"false"}
TRAEFIK_ADMIN_PORT=${TRAEFIK_ADMIN_PORT:-"8888"}
TRAEFIK_LOG_LEVEL=${TRAEFIK_LOG_LEVEL:-"ERROR"}

TRAEFIK_ENTRYPOINTS_OPTS="\
entryPoints:
  traefik:
    address: \":${TRAEFIK_ADMIN_PORT}\"
"

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
TRAEFIK_ENTRYPOINTS_BEDROCK="\
  bedrock:
    address: \":${CBWXPROXY_BEDROCK_PORT}/udp\"
"
TRAEFIK_BEDROCK_OPTS="\
udp:
  routers:
    bedrock:
      entryPoints:
        - \"bedrock\"
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
TRAEFIK_ENTRYPOINTS_JAVA="\
  java:
    address: \":${CBWXPROXY_JAVA_PORT}\"
"
TRAEFIK_JAVA_OPTS="\
tcp:
  routers:
    java:
      entryPoints:
        - \"java\"
      rule: \"HostSNI(\`*\`)\"
      service: \"java\"
  services:
    java:
      loadBalancer:
        servers:
        -  address: \"${CBWXPROXY_JAVA_REMOTE_HOST}\"
"
  fi
}

config_traefik_admin() {
  if [[ "x${TRAEFIK_ADMIN_ENABLE}" == "xtrue" ]]; then
    if [[ "x${TRAEFIK_ADMIN_PORT}" != "x" ]]; then
      if [[ "${TRAEFIK_ADMIN_PORT}" -lt 1 ]] && [[ "${TRAEFIK_ADMIN_PORT}" -gt 65535 ]]; then
        echo "ERROR: TRAEFIK_ADMIN_PORT must be a number between 1-65535!"
        exit 1
      fi
    fi
TRAEFIK_ADMIN_OPTS="\
api:
  dashboard: true
  debug: ${TRAEFIK_ADMIN_DEBUG}
  insecure: true
"
  fi
}

write_config() {
  TRAEFIK_ENTRYPOINTS_OPTS=${TRAEFIK_ENTRYPOINTS_OPTS}${TRAEFIK_ENTRYPOINTS_BEDROCK}${TRAEFIK_ENTRYPOINTS_JAVA}
cat << EOF > /etc/traefik.yaml
# traefik.yaml
global:
  checkNewVersion: false
  sendAnonymousUsage: false
log:
  level: "${TRAEFIK_LOG_LEVEL}"
accessLog: {}
ping:
  entryPoint: "traefik"
providers:
  file:
    filename: /etc/provider.yaml
${TRAEFIK_ADMIN_OPTS}
${TRAEFIK_ENTRYPOINTS_OPTS}
EOF
cat << EOF > /etc/provider.yaml
${TRAEFIK_BEDROCK_OPTS}
${TRAEFIK_JAVA_OPTS}
EOF
}

#Check enabled
if [[ "x${CBWXPROXY_BEDROCK_ENABLE}" != "xtrue" ]] && [[ "x${CBWXPROXY_JAVA_ENABLE}" != "xtrue" ]]; then
  echo "ERROR: Either CBWXPROXY_BEDROCK_ENABLE or CBWXPROXY_JAVA_ENABLE variable must be TRUE!"
  exit 1
fi

#Check bedrock
config_bedrock
#Check java
config_java
#Check traefik admin
config_traefik_admin
#Write config file
write_config

exec traefik --configFile=/etc/traefik.yaml
