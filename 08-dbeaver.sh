#!/usr/bin/env bash
# 08-dbeaver.sh - DBeaver Community Edition (repositório oficial).
source "$(dirname "$0")/00-common.sh"
detect_ubuntu
require_sudo

# Necessita de Java; o repositório do DBeaver já traz JRE empacotada,
# mas garantimos dependências básicas.
log "Configurando repositório do DBeaver..."
apt_install curl gnupg ca-certificates

${SUDO} install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://dbeaver.io/debs/dbeaver.gpg.key \
  | ${SUDO} gpg --dearmor -o /etc/apt/keyrings/dbeaver.gpg
${SUDO} chmod a+r /etc/apt/keyrings/dbeaver.gpg

echo "deb [signed-by=/etc/apt/keyrings/dbeaver.gpg] https://dbeaver.io/debs/dbeaver-ce /" \
  | ${SUDO} tee /etc/apt/sources.list.d/dbeaver.list > /dev/null

export _APT_UPDATED=""
apt_install dbeaver-ce

ok "DBeaver instalado. Abra pelo menu de aplicativos ou rode: dbeaver-ce"
