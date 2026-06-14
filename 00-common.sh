#!/usr/bin/env bash
# 00-common.sh - Funções utilitárias compartilhadas pelos demais scripts.
# Uso: source ./00-common.sh

set -Eeuo pipefail

# Cores
if [[ -t 1 ]]; then
  C_RESET="\033[0m"; C_INFO="\033[1;34m"; C_OK="\033[1;32m"; C_WARN="\033[1;33m"; C_ERR="\033[1;31m"
else
  C_RESET=""; C_INFO=""; C_OK=""; C_WARN=""; C_ERR=""
fi

log()  { echo -e "${C_INFO}[INFO]${C_RESET} $*"; }
ok()   { echo -e "${C_OK}[ OK ]${C_RESET} $*"; }
warn() { echo -e "${C_WARN}[WARN]${C_RESET} $*"; }
err()  { echo -e "${C_ERR}[ERRO]${C_RESET} $*" >&2; }

require_sudo() {
  if [[ "${EUID}" -eq 0 ]]; then
    SUDO=""
  elif command -v sudo >/dev/null 2>&1; then
    SUDO="sudo"
  else
    err "sudo não encontrado e você não é root."; exit 1
  fi
}

apt_update_once() {
  if [[ -z "${_APT_UPDATED:-}" ]]; then
    log "Atualizando índice de pacotes (apt update)..."
    ${SUDO} apt-get update -y
    export _APT_UPDATED=1
  fi
}

apt_install() {
  apt_update_once
  log "Instalando: $*"
  ${SUDO} DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends "$@"
}

has() { command -v "$1" >/dev/null 2>&1; }

# Acrescenta uma linha ao ~/.bashrc só se ainda não existir.
add_to_bashrc() {
  local line="$1"
  local rc="${HOME}/.bashrc"
  grep -qsF -- "$line" "$rc" 2>/dev/null || echo "$line" >> "$rc"
}

detect_ubuntu() {
  if ! grep -qi ubuntu /etc/os-release 2>/dev/null; then
    warn "Este script foi pensado para Ubuntu. Prosseguindo mesmo assim."
  fi
}
