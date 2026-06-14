#!/usr/bin/env bash
# 09-hadoop.sh - Apache Hadoop em modo pseudo-distribuído (single node).
source "$(dirname "$0")/00-common.sh"
detect_ubuntu
require_sudo

HADOOP_VERSION="${HADOOP_VERSION:-3.4.0}"
INSTALL_DIR="${INSTALL_DIR:-/opt}"
HADOOP_HOME="${INSTALL_DIR}/hadoop"
MIRROR="https://dlcdn.apache.org/hadoop/common/hadoop-${HADOOP_VERSION}/hadoop-${HADOOP_VERSION}.tar.gz"

log "Instalando Java (OpenJDK) e SSH — requisitos do Hadoop..."
apt_install openjdk-17-jdk ssh rsync curl

# Descobre JAVA_HOME
JAVA_HOME_DIR="$(dirname "$(dirname "$(readlink -f "$(command -v java)")")")"
log "JAVA_HOME detectado: ${JAVA_HOME_DIR}"

if [[ ! -d "${HADOOP_HOME}" ]]; then
  log "Baixando Hadoop ${HADOOP_VERSION}..."
  curl -fsSL "$MIRROR" -o "/tmp/hadoop.tar.gz"
  ${SUDO} tar -xzf /tmp/hadoop.tar.gz -C "${INSTALL_DIR}"
  ${SUDO} ln -sfn "${INSTALL_DIR}/hadoop-${HADOOP_VERSION}" "${HADOOP_HOME}"
  ${SUDO} chown -R "${USER}:${USER}" "${INSTALL_DIR}/hadoop-${HADOOP_VERSION}"
  rm -f /tmp/hadoop.tar.gz
else
  ok "Hadoop já presente em ${HADOOP_HOME}"
fi

# Variáveis de ambiente
add_to_bashrc "export HADOOP_HOME=${HADOOP_HOME}"
add_to_bashrc 'export HADOOP_INSTALL=$HADOOP_HOME'
add_to_bashrc 'export HADOOP_MAPRED_HOME=$HADOOP_HOME'
add_to_bashrc 'export HADOOP_COMMON_HOME=$HADOOP_HOME'
add_to_bashrc 'export HADOOP_HDFS_HOME=$HADOOP_HOME'
add_to_bashrc 'export YARN_HOME=$HADOOP_HOME'
add_to_bashrc 'export HADOOP_COMMON_LIB_NATIVE_DIR=$HADOOP_HOME/lib/native'
add_to_bashrc 'export PATH=$PATH:$HADOOP_HOME/bin:$HADOOP_HOME/sbin'
add_to_bashrc "export JAVA_HOME=${JAVA_HOME_DIR}"

# Define JAVA_HOME no hadoop-env.sh
ENV_FILE="${HADOOP_HOME}/etc/hadoop/hadoop-env.sh"
if ! grep -q "export JAVA_HOME=${JAVA_HOME_DIR}" "$ENV_FILE" 2>/dev/null; then
  echo "export JAVA_HOME=${JAVA_HOME_DIR}" >> "$ENV_FILE"
fi

log "Aplicando configuração pseudo-distribuída..."
CFG="${HADOOP_HOME}/etc/hadoop"

cat > "${CFG}/core-site.xml" <<'EOF'
<?xml version="1.0"?>
<configuration>
  <property>
    <name>fs.defaultFS</name>
    <value>hdfs://localhost:9000</value>
  </property>
</configuration>
EOF

cat > "${CFG}/hdfs-site.xml" <<'EOF'
<?xml version="1.0"?>
<configuration>
  <property>
    <name>dfs.replication</name>
    <value>1</value>
  </property>
</configuration>
EOF

cat > "${CFG}/mapred-site.xml" <<'EOF'
<?xml version="1.0"?>
<configuration>
  <property>
    <name>mapreduce.framework.name</name>
    <value>yarn</value>
  </property>
  <property>
    <name>mapreduce.application.classpath</name>
    <value>$HADOOP_MAPRED_HOME/share/hadoop/mapreduce/*:$HADOOP_MAPRED_HOME/share/hadoop/mapreduce/lib/*</value>
  </property>
</configuration>
EOF

cat > "${CFG}/yarn-site.xml" <<'EOF'
<?xml version="1.0"?>
<configuration>
  <property>
    <name>yarn.nodemanager.aux-services</name>
    <value>mapreduce_shuffle</value>
  </property>
  <property>
    <name>yarn.nodemanager.env-whitelist</name>
    <value>JAVA_HOME,HADOOP_COMMON_HOME,HADOOP_HDFS_HOME,HADOOP_CONF_DIR,CLASSPATH_PREPEND_DISTCACHE,HADOOP_YARN_HOME,HADOOP_MAPRED_HOME</value>
  </property>
</configuration>
EOF

# SSH sem senha p/ localhost (necessário para start-dfs.sh)
if [[ ! -f "${HOME}/.ssh/id_rsa" ]]; then
  log "Gerando chave SSH para acesso sem senha ao localhost..."
  ssh-keygen -t rsa -P '' -f "${HOME}/.ssh/id_rsa"
  cat "${HOME}/.ssh/id_rsa.pub" >> "${HOME}/.ssh/authorized_keys"
  chmod 0600 "${HOME}/.ssh/authorized_keys"
fi

cat <<EOF

${C_OK}Hadoop instalado em ${HADOOP_HOME}${C_RESET}
Próximos passos (abra um novo terminal primeiro):
  1) Formatar o NameNode:   hdfs namenode -format
  2) Iniciar HDFS:          start-dfs.sh
  3) Iniciar YARN:          start-yarn.sh
  4) Interfaces web:        HDFS http://localhost:9870  |  YARN http://localhost:8088
EOF
