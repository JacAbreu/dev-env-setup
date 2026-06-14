#!/usr/bin/env bash
# 06-node.sh - Node.js via nvm + ferramentas (Express generator, Next.js, etc.)
source "$(dirname "$0")/00-common.sh"
detect_ubuntu
require_sudo

NODE_VERSION="${NODE_VERSION:-22}"     # LTS major
NVM_VERSION="${NVM_VERSION:-v0.40.1}"

log "Instalando dependências..."
apt_install curl git ca-certificates

export NVM_DIR="${HOME}/.nvm"
if [[ ! -d "$NVM_DIR" ]]; then
  log "Instalando nvm ${NVM_VERSION}..."
  curl -fsSL "https://raw.githubusercontent.com/nvm-sh/nvm/${NVM_VERSION}/install.sh" | bash
else
  ok "nvm já instalado."
fi

# bashrc já recebe linhas do instalador do nvm; carregamos aqui também
set +u
source "${NVM_DIR}/nvm.sh"
set -u

log "Instalando Node.js ${NODE_VERSION} (LTS)..."
nvm install "${NODE_VERSION}"
nvm alias default "${NODE_VERSION}"
nvm use default

log "Atualizando npm e habilitando corepack (yarn/pnpm)..."
npm install -g npm@latest
corepack enable || warn "corepack não disponível"

log "Instalando ferramentas globais (Express generator, Next, TS, nodemon)..."
npm install -g \
  express-generator \
  create-next-app \
  typescript ts-node \
  nodemon eslint prettier

cat <<'EOF'

Dicas de uso:
  Express:  express --no-view minha-api        # gera projeto Express
  Next.js:  npx create-next-app@latest meu-app  # cria projeto Next.js
EOF

ok "Node pronto. Verifique com: node -v && npm -v"
