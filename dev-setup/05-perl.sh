#!/usr/bin/env bash
# 05-perl.sh - Perl via Perlbrew + cpanm e módulos comuns.
source "$(dirname "$0")/00-common.sh"
detect_ubuntu
require_sudo

PERL_VERSION="${PERL_VERSION:-perl-5.40.0}"

log "Instalando dependências..."
apt_install build-essential curl git ca-certificates

export PERLBREW_ROOT="${HOME}/perl5/perlbrew"
if [[ ! -d "$PERLBREW_ROOT" ]]; then
  log "Instalando Perlbrew..."
  curl -fsSL https://install.perlbrew.pl | bash
else
  ok "Perlbrew já instalado."
fi

add_to_bashrc 'source ~/perl5/perlbrew/etc/bashrc'
set +u
source "${HOME}/perl5/perlbrew/etc/bashrc"
set -u

log "Instalando ${PERL_VERSION} (compila do código-fonte, pode demorar)..."
perlbrew install -j "$(nproc)" --notest "${PERL_VERSION}" || warn "Versão já instalada ou falhou."
perlbrew switch "${PERL_VERSION}" || true

log "Instalando cpanm..."
perlbrew install-cpanm || true

log "Instalando módulos Perl comuns..."
cpanm --notest \
  Try::Tiny JSON JSON::XS YAML LWP::UserAgent Mojolicious \
  DBI DBD::Pg DBD::SQLite Moose Path::Tiny Test::More \
  Perl::Critic Perl::Tidy || warn "Alguns módulos podem ter falhado."

ok "Perl pronto. Verifique com: perl -v && cpanm --version"
