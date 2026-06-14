# Dev Setup — Ubuntu

Scripts para configurar um ambiente de desenvolvimento no Ubuntu, separados por
linguagem/tecnologia. Cada script é independente e idempotente (pode rodar de novo
sem quebrar o que já está instalado).

## Componentes

| Script            | O que instala                                                                 |
|-------------------|-------------------------------------------------------------------------------|
| `01-golang.sh`    | Go (toolchain oficial) + gopls, dlv, golangci-lint                            |
| `02-java.sh`      | Java (Temurin) via SDKMAN + Maven + Gradle                                    |
| `03-python.sh`    | Python via pyenv + venvs `django` (Django/DRF) e `dataeng` (pandas, Spark, Airflow, dbt, Jupyter...) |
| `04-ruby.sh`      | Ruby via rbenv + Bundler + Rails                                              |
| `05-perl.sh`      | Perl via Perlbrew + cpanm + módulos comuns (Mojolicious, DBI, Moose...)        |
| `06-node.sh`      | Node.js via nvm + Express generator + create-next-app + TS                    |
| `07-docker.sh`    | Docker Engine + Compose (repo oficial)                                         |
| `08-dbeaver.sh`   | DBeaver Community Edition                                                      |
| `09-hadoop.sh`    | Apache Hadoop pseudo-distribuído (single node)                                 |
| `10-spark.sh`     | Apache Spark standalone (+ integração com Hadoop se presente)                 |

## Uso

```bash
# Dar permissão de execução
chmod +x *.sh

# Instalar tudo
./install.sh all

# Instalar apenas alguns
./install.sh golang python docker

# Menu interativo
./install.sh

# Rodar um componente isolado
./03-python.sh
```

> Após a instalação, **abra um novo terminal** (ou `source ~/.bashrc`) para
> carregar as variáveis de ambiente. Para Docker, faça logout/login para usar
> sem `sudo`.

## Personalização

Cada script aceita variáveis de versão por ambiente. Exemplos:

```bash
GO_VERSION=1.22.4      ./01-golang.sh
JAVA_VERSION=21.0.3-tem ./02-java.sh
PYTHON_VERSION=3.12.4  ./03-python.sh
RUBY_VERSION=3.3.4 RAILS_VERSION=7.1 ./04-ruby.sh
NODE_VERSION=22        ./06-node.sh
HADOOP_VERSION=3.4.0   ./09-hadoop.sh
SPARK_VERSION=3.5.1    ./10-spark.sh
```

## Observações

- **Versões**: confira a versão mais recente de cada ferramenta antes de rodar em
  produção — as definidas aqui eram atuais no momento da criação. URLs de download
  (Go, Hadoop, Spark) podem mudar; ajuste a variável de versão se algum link falhar.
- **Hadoop/Spark**: pensados para ambiente local de estudo/desenvolvimento
  (single node), não para produção.
- **Python**: os ambientes ficam isolados em `pyenv` —
  `pyenv activate django` ou `pyenv activate dataeng`.
- Os scripts usam `set -Eeuo pipefail`; se algo falhar, eles param para você ver o erro.
