#!/usr/bin/env bash
# install.sh - Orquestrador. Permite instalar tudo ou selecionar componentes.
#
# Uso:
#   ./install.sh                 # menu interativo
#   ./install.sh all             # instala tudo, na ordem
#   ./install.sh golang python docker   # instala apenas os listados
#
# Componentes válidos:
#   golang java python ruby perl node docker dbeaver hadoop spark
source "$(dirname "$0")/00-common.sh"

declare -A SCRIPTS=(
  [golang]=01-golang.sh
  [java]=02-java.sh
  [python]=03-python.sh
  [ruby]=04-ruby.sh
  [perl]=05-perl.sh
  [node]=06-node.sh
  [docker]=07-docker.sh
  [dbeaver]=08-dbeaver.sh
  [hadoop]=09-hadoop.sh
  [spark]=10-spark.sh
)

ORDER=(golang java python ruby perl node docker dbeaver hadoop spark)
HERE="$(cd "$(dirname "$0")" && pwd)"

run_one() {
  local key="$1"
  local script="${SCRIPTS[$key]:-}"
  if [[ -z "$script" ]]; then
    err "Componente desconhecido: $key"; return 1
  fi
  echo "============================================================"
  log "Instalando: $key  (${script})"
  echo "============================================================"
  bash "${HERE}/${script}"
  ok "Concluído: $key"
  echo
}

main() {
  detect_ubuntu
  local targets=()

  if [[ $# -eq 0 ]]; then
    echo "Selecione os componentes (separados por espaço) ou digite 'all':"
    echo "  ${ORDER[*]}"
    read -rp "> " -a targets
    [[ "${targets[*]:-}" == "all" ]] && targets=("${ORDER[@]}")
  elif [[ "$1" == "all" ]]; then
    targets=("${ORDER[@]}")
  else
    targets=("$@")
  fi

  for t in "${targets[@]}"; do
    run_one "$t" || warn "Falha em $t — seguindo para o próximo."
  done

  ok "Tudo finalizado. Abra um NOVO terminal para carregar as variáveis de ambiente."
}

main "$@"
