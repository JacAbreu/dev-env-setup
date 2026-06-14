#!/usr/bin/env bash
# 02-java.sh - Instala Java via SDKMAN (Temurin) + Maven e Gradle.
source "$(dirname "$0")/00-common.sh"
detect_ubuntu
require_sudo

JAVA_VERSION="${JAVA_VERSION:-21.0.3-tem}"   # ver 'sdk list java' p/ outras

log "Instalando dependências (curl, zip, unzip)..."
apt_install curl zip unzip ca-certificates

export SDKMAN_DIR="${HOME}/.sdkman"
if [[ ! -d "$SDKMAN_DIR" ]]; then
  log "Instalando SDKMAN..."
  curl -fsSL "https://get.sdkman.io" | bash
else
  ok "SDKMAN já instalado."
fi

# Carrega SDKMAN nesta sessão
set +u
source "${SDKMAN_DIR}/bin/sdkman-init.sh"
set -u

log "Instalando Java ${JAVA_VERSION}..."
sdk install java "${JAVA_VERSION}" || warn "Java ${JAVA_VERSION} pode já estar instalado."
sdk default java "${JAVA_VERSION}" || true

log "Instalando Maven e Gradle..."
sdk install maven  || warn "Maven já instalado."
sdk install gradle || warn "Gradle já instalado."

ok "Java pronto. Abra um novo terminal e verifique: java -version && mvn -v && gradle -v"
