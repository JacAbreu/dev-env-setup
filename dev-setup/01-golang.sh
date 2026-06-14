#!/usr/bin/env bash
# 01-golang.sh - Instala Go (toolchain oficial) + ferramentas comuns.
source "$(dirname "$0")/00-common.sh"
detect_ubuntu
require_sudo

GO_VERSION="${GO_VERSION:-1.22.4}"
GO_ARCH="$(dpkg --print-architecture)"   # amd64 / arm64
GO_TARBALL="go${GO_VERSION}.linux-${GO_ARCH}.tar.gz"
GO_URL="https://go.dev/dl/${GO_TARBALL}"

log "Instalando dependências básicas..."
apt_install ca-certificates curl git

if has go && go version | grep -q "go${GO_VERSION}"; then
  ok "Go ${GO_VERSION} já instalado."
else
  log "Baixando ${GO_URL}"
  curl -fsSL "$GO_URL" -o "/tmp/${GO_TARBALL}"
  log "Removendo instalação anterior em /usr/local/go (se houver)..."
  ${SUDO} rm -rf /usr/local/go
  ${SUDO} tar -C /usr/local -xzf "/tmp/${GO_TARBALL}"
  rm -f "/tmp/${GO_TARBALL}"
  ok "Go ${GO_VERSION} instalado em /usr/local/go"
fi

# PATH e GOPATH
add_to_bashrc 'export PATH=$PATH:/usr/local/go/bin'
add_to_bashrc 'export GOPATH=$HOME/go'
add_to_bashrc 'export PATH=$PATH:$GOPATH/bin'
export PATH=$PATH:/usr/local/go/bin
export GOPATH=$HOME/go
export PATH=$PATH:$GOPATH/bin
mkdir -p "$HOME/go/bin"

log "Instalando ferramentas Go (gopls, dlv, golangci-lint)..."
go install golang.org/x/tools/gopls@latest || warn "Falha ao instalar gopls"
go install github.com/go-delve/delve/cmd/dlv@latest || warn "Falha ao instalar dlv"
go install github.com/golangci/golangci-lint/cmd/golangci-lint@latest || warn "Falha ao instalar golangci-lint"

ok "Go pronto. Verifique com: go version"
