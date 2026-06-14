#!/usr/bin/env bash
# 10-spark.sh - Apache Spark (standalone). Integra com Hadoop se presente.
source "$(dirname "$0")/00-common.sh"
detect_ubuntu
require_sudo

SPARK_VERSION="${SPARK_VERSION:-3.5.1}"
HADOOP_PROFILE="${HADOOP_PROFILE:-3}"   # "3" => binário hadoop3
INSTALL_DIR="${INSTALL_DIR:-/opt}"
SPARK_HOME="${INSTALL_DIR}/spark"
PKG="spark-${SPARK_VERSION}-bin-hadoop${HADOOP_PROFILE}"
MIRROR="https://dlcdn.apache.org/spark/spark-${SPARK_VERSION}/${PKG}.tgz"

log "Instalando Java (OpenJDK) e Python — requisitos do Spark..."
apt_install openjdk-17-jdk python3 python3-pip curl

JAVA_HOME_DIR="$(dirname "$(dirname "$(readlink -f "$(command -v java)")")")"

if [[ ! -d "${SPARK_HOME}" ]]; then
  log "Baixando Spark ${SPARK_VERSION} (${PKG})..."
  curl -fsSL "$MIRROR" -o "/tmp/spark.tgz"
  ${SUDO} tar -xzf /tmp/spark.tgz -C "${INSTALL_DIR}"
  ${SUDO} ln -sfn "${INSTALL_DIR}/${PKG}" "${SPARK_HOME}"
  ${SUDO} chown -R "${USER}:${USER}" "${INSTALL_DIR}/${PKG}"
  rm -f /tmp/spark.tgz
else
  ok "Spark já presente em ${SPARK_HOME}"
fi

add_to_bashrc "export SPARK_HOME=${SPARK_HOME}"
add_to_bashrc 'export PATH=$PATH:$SPARK_HOME/bin:$SPARK_HOME/sbin'
add_to_bashrc "export JAVA_HOME=${JAVA_HOME_DIR}"
add_to_bashrc 'export PYSPARK_PYTHON=python3'

# Se Hadoop estiver instalado, aponta para a config dele (modo YARN opcional)
if [[ -d "${INSTALL_DIR}/hadoop" ]]; then
  add_to_bashrc 'export HADOOP_CONF_DIR=$HADOOP_HOME/etc/hadoop'
  log "Hadoop detectado: HADOOP_CONF_DIR configurado (Spark pode usar --master yarn)."
fi

log "Instalando PySpark via pip (opcional, facilita uso em Python)..."
pip3 install --user "pyspark==${SPARK_VERSION}" || warn "Falha ao instalar pyspark via pip."

cat <<EOF

${C_OK}Spark instalado em ${SPARK_HOME}${C_RESET}
Teste (abra um novo terminal primeiro):
  spark-shell        # Scala REPL
  pyspark            # Python REPL
  start-master.sh && start-worker.sh spark://\$(hostname):7077   # cluster standalone
  Spark UI: http://localhost:8080
EOF
