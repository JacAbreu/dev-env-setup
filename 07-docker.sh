#!/usr/bin/env bash
# 07-docker.sh - Docker Engine + Compose (repositório oficial Docker).
source "$(dirname "$0")/00-common.sh"
detect_ubuntu
require_sudo

log "Removendo pacotes conflitantes antigos (se houver)..."
for pkg in docker.io docker-doc docker-compose docker-compose-v2 podman-docker containerd runc; do
  ${SUDO} apt-get remove -y "$pkg" >/dev/null 2>&1 || true
done

log "Configurando repositório oficial do Docker..."
apt_install ca-certificates curl gnupg
${SUDO} install -m 0755 -d /etc/apt/keyrings
${SUDO} curl -fsSL https://download.docker.com/linux/ubuntu/gpg \
  -o /etc/apt/keyrings/docker.asc
${SUDO} chmod a+r /etc/apt/keyrings/docker.asc

ARCH="$(dpkg --print-architecture)"
CODENAME="$(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}")"
echo \
  "deb [arch=${ARCH} signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu ${CODENAME} stable" \
  | ${SUDO} tee /etc/apt/sources.list.d/docker.list > /dev/null

export _APT_UPDATED=""   # força novo apt update p/ novo repo
apt_install docker-ce docker-ce-cli containerd.io \
  docker-buildx-plugin docker-compose-plugin

log "Adicionando ${USER} ao grupo docker..."
${SUDO} groupadd docker 2>/dev/null || true
${SUDO} usermod -aG docker "${USER}" || true

${SUDO} systemctl enable docker >/dev/null 2>&1 || true
${SUDO} systemctl start docker  >/dev/null 2>&1 || true

ok "Docker instalado. Faça logout/login (ou 'newgrp docker') para usar sem sudo."
ok "Teste com: docker run hello-world"
