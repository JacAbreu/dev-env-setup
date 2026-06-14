#!/usr/bin/env bash
# 04-ruby.sh - Ruby via rbenv + ruby-build, com Bundler e Rails.
source "$(dirname "$0")/00-common.sh"
detect_ubuntu
require_sudo

RUBY_VERSION="${RUBY_VERSION:-3.3.4}"
RAILS_VERSION="${RAILS_VERSION:-7.1}"

log "Instalando dependências de build do Ruby..."
apt_install git curl autoconf bison build-essential libssl-dev \
  libyaml-dev libreadline-dev zlib1g-dev libncurses-dev libffi-dev \
  libgdbm-dev libjemalloc2 \
  libpq-dev libsqlite3-dev nodejs

export RBENV_ROOT="${HOME}/.rbenv"
if [[ ! -d "$RBENV_ROOT" ]]; then
  log "Instalando rbenv..."
  git clone https://github.com/rbenv/rbenv.git "$RBENV_ROOT"
  git clone https://github.com/rbenv/ruby-build.git "$RBENV_ROOT/plugins/ruby-build"
else
  ok "rbenv já instalado."
fi

add_to_bashrc 'export RBENV_ROOT="$HOME/.rbenv"'
add_to_bashrc 'export PATH="$RBENV_ROOT/bin:$PATH"'
add_to_bashrc 'eval "$(rbenv init - bash)"'

export PATH="$RBENV_ROOT/bin:$PATH"
eval "$(rbenv init - bash)"

log "Instalando Ruby ${RUBY_VERSION} (pode demorar)..."
rbenv install -s "${RUBY_VERSION}"
rbenv global "${RUBY_VERSION}"
rbenv rehash

log "Configurando gems..."
gem update --system || true
gem install bundler
gem install rails -v "${RAILS_VERSION}"
rbenv rehash

ok "Ruby pronto. Verifique com: ruby -v && rails -v"
