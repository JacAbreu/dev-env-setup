#!/usr/bin/env bash
# 03-python.sh - Python via pyenv + virtualenv com dois ambientes:
#   - django      : desenvolvimento web (Django + DRF)
#   - dataeng     : engenharia/análise de dados (pandas, polars, jupyter, etc.)
source "$(dirname "$0")/00-common.sh"
detect_ubuntu
require_sudo

PYTHON_VERSION="${PYTHON_VERSION:-3.12.4}"

log "Instalando dependências de build do Python..."
apt_install make build-essential libssl-dev zlib1g-dev libbz2-dev \
  libreadline-dev libsqlite3-dev wget curl llvm libncursesw5-dev \
  xz-utils tk-dev libxml2-dev libxmlsec1-dev libffi-dev liblzma-dev \
  git ca-certificates

export PYENV_ROOT="${HOME}/.pyenv"
if [[ ! -d "$PYENV_ROOT" ]]; then
  log "Instalando pyenv..."
  curl -fsSL https://pyenv.run | bash
else
  ok "pyenv já instalado."
fi

add_to_bashrc 'export PYENV_ROOT="$HOME/.pyenv"'
add_to_bashrc '[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"'
add_to_bashrc 'eval "$(pyenv init - bash)"'
add_to_bashrc 'eval "$(pyenv virtualenv-init -)"'

export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init - bash)"
eval "$(pyenv virtualenv-init -)" 2>/dev/null || true

log "Instalando Python ${PYTHON_VERSION} (pode demorar)..."
pyenv install -s "${PYTHON_VERSION}"
pyenv global "${PYTHON_VERSION}"

python -m pip install --upgrade pip setuptools wheel

# ---- Ambiente Django ----
log "Criando virtualenv 'django'..."
pyenv virtualenv -f "${PYTHON_VERSION}" django
"${PYENV_ROOT}/versions/django/bin/pip" install --upgrade pip
"${PYENV_ROOT}/versions/django/bin/pip" install \
  django djangorestframework django-environ psycopg2-binary \
  gunicorn celery redis black flake8 pytest pytest-django

# ---- Ambiente Data Engineering / Analysis ----
log "Criando virtualenv 'dataeng'..."
pyenv virtualenv -f "${PYTHON_VERSION}" dataeng
"${PYENV_ROOT}/versions/dataeng/bin/pip" install --upgrade pip
"${PYENV_ROOT}/versions/dataeng/bin/pip" install \
  numpy pandas polars pyarrow duckdb \
  matplotlib seaborn plotly \
  scikit-learn statsmodels \
  jupyterlab notebook ipykernel \
  sqlalchemy psycopg2-binary \
  requests beautifulsoup4 \
  apache-airflow dbt-core dbt-postgres \
  pyspark openpyxl

# Registra kernels Jupyter
"${PYENV_ROOT}/versions/dataeng/bin/python" -m ipykernel install --user --name dataeng --display-name "Python (dataeng)" || true

ok "Python pronto. Ative ambientes com: pyenv activate django  ou  pyenv activate dataeng"
