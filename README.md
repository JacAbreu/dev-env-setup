# Dev Setup — Ubuntu

Scripts para configurar um ambiente de desenvolvimento no Ubuntu, separados por
linguagem/tecnologia. Cada script é idempotente (pode rodar de novo sem quebrar o
que já está instalado) e, com exceção de duas dependências entre
Hadoop/Spark/Java, independente dos demais. Veja a seção
[Ordem de execução](#ordem-de-execução) para detalhes.

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

## Ordem de execução

### `00-common.sh` — NÃO é executado diretamente

O `00-common.sh` contém apenas funções utilitárias compartilhadas. Ele **não
deve ser rodado sozinho** — cada script o carrega automaticamente (via `source`)
logo na primeira linha:

```bash
source "$(dirname "$0")/00-common.sh"
```

Ou seja, ao rodar qualquer script (ex.: `./03-python.sh`), o `00-common.sh` já é
puxado sozinho antes de qualquer instalação. A única exigência é que ele
**permaneça na mesma pasta** dos demais scripts. Você nunca precisa executá-lo
manualmente.

### A ordem entre os scripts numerados importa?

Na maioria dos casos **não**. Go, Java, Python, Ruby, Perl, Node, Docker e
DBeaver são totalmente independentes e podem ser instalados em qualquer ordem,
isolados ou juntos.

Existem **duas dependências** que valem ser respeitadas:

1. **Spark depois de Hadoop** (`10-spark.sh` após `09-hadoop.sh`). O Spark detecta
   se o Hadoop está instalado em `/opt/hadoop` e, se estiver, configura o
   `HADOOP_CONF_DIR` para permitir o modo YARN (`--master yarn`). Instalado antes
   do Hadoop, o Spark funciona normalmente em modo standalone, mas perde essa
   integração automática.

2. **Java antes de Hadoop/Spark** (opcional). Os scripts `09-hadoop.sh` e
   `10-spark.sh` instalam o próprio OpenJDK internamente, então funcionam sozinhos.
   Rodar o `02-java.sh` (Temurin via SDKMAN) antes não é obrigatório — apenas saiba
   que você terá duas instalações de Java convivendo (não quebra nada).

### O `install.sh` já cuida disso

O orquestrador executa na ordem numérica
(`golang → java → python → ruby → perl → node → docker → dbeaver → hadoop → spark`),
que já respeita as duas dependências acima (Java antes de Hadoop/Spark, e Hadoop
antes de Spark). Portanto, com `./install.sh all` você não precisa se preocupar
com ordem nenhuma.

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


# MAINTENANCE — Como manter os scripts atualizados

Guia para atualizar os scripts de instalação quando saírem novas versões das
ferramentas. A ideia central: **quase nada precisa ser editado no corpo dos
scripts** — a maioria das versões é controlada por uma variável no topo do
arquivo (ou via variável de ambiente na hora de rodar).

> Regra de ouro: antes de fixar uma versão nova, confira a página oficial de
> releases (links na tabela abaixo) e teste o script numa máquina/VM limpa.

---

## 1. Visão geral — o que muda em cada script

Cada script define a versão alvo numa variável logo no início, no padrão
`VAR="${VAR:-valor}"`. Isso significa que você pode:

- **editar o valor padrão** dentro do script (fica fixo para todos), **ou**
- **sobrescrever na hora de rodar**, sem tocar no arquivo:
  ```bash
  GO_VERSION=1.26.4 ./01-golang.sh
  ```

| Script           | Variável(is) a atualizar                          | O que representa                          |
|------------------|---------------------------------------------------|-------------------------------------------|
| `01-golang.sh`   | `GO_VERSION`                                       | versão do Go (ex.: `1.26.4`)              |
| `02-java.sh`     | `JAVA_VERSION`                                     | identificador SDKMAN (ex.: `21.0.3-tem`)  |
| `03-python.sh`   | `PYTHON_VERSION`                                   | versão do CPython (ex.: `3.12.4`)         |
| `04-ruby.sh`     | `RUBY_VERSION`, `RAILS_VERSION`                    | versão do Ruby e do Rails                 |
| `05-perl.sh`     | `PERL_VERSION`                                     | versão do Perl (ex.: `perl-5.40.0`)       |
| `06-node.sh`     | `NODE_VERSION`, `NVM_VERSION`                      | major do Node LTS e versão do nvm         |
| `07-docker.sh`   | — (usa repositório oficial, sempre a mais recente) | nada a fixar                              |
| `08-dbeaver.sh`  | — (usa repositório oficial, sempre a mais recente) | nada a fixar                              |
| `09-hadoop.sh`   | `HADOOP_VERSION`                                   | versão do Hadoop (ex.: `3.4.0`)           |
| `10-spark.sh`    | `SPARK_VERSION`, `HADOOP_PROFILE`                  | versão do Spark e perfil Hadoop do binário|

Em `00-common.sh` não há versões — são só funções utilitárias. Raramente precisa
de manutenção.

---

## 2. Onde checar a versão mais recente (fontes oficiais)

| Ferramenta | Página oficial de releases                                            |
|------------|----------------------------------------------------------------------|
| Go         | https://go.dev/dl/  •  notas: https://go.dev/doc/devel/release        |
| Java/Temurin | https://adoptium.net/temurin/releases/  •  ou `sdk list java`       |
| Maven/Gradle | `sdk list maven` / `sdk list gradle`                               |
| Python     | https://www.python.org/downloads/  •  `pyenv install --list`         |
| Ruby       | https://www.ruby-lang.org/en/downloads/  •  `rbenv install --list`   |
| Rails      | https://rubygems.org/gems/rails/versions                             |
| Perl       | https://www.perl.org/get.html  •  `perlbrew available`               |
| Node.js    | https://nodejs.org/en/download/  (use a linha **LTS**)               |
| nvm        | https://github.com/nvm-sh/nvm/releases                               |
| Docker     | https://docs.docker.com/engine/install/ubuntu/  (repo sempre atual)  |
| DBeaver    | https://dbeaver.io/download/  (repo sempre atual)                    |
| Hadoop     | https://hadoop.apache.org/releases.html                              |
| Spark      | https://spark.apache.org/downloads.html                              |

---

## 3. Passo a passo por ferramenta

### Go (`01-golang.sh`)
1. Veja a versão mais recente em https://go.dev/dl/ (ex.: `go1.26.4`).
2. Atualize `GO_VERSION` (sem o prefixo `go`): `GO_VERSION="${GO_VERSION:-1.26.4}"`.
3. O script já monta a URL automaticamente a partir da versão e da arquitetura
   (`go${VERSION}.linux-${arch}.tar.gz`), então **só a variável precisa mudar**.
4. As ferramentas (`gopls`, `dlv`, `golangci-lint`) usam `@latest` — atualizam
   sozinhas, sem edição.

### Java (`02-java.sh`)
1. Rode `sdk list java` para ver os identificadores disponíveis (a coluna
   "Identifier", ex.: `21.0.5-tem`).
2. Atualize `JAVA_VERSION` com o identificador exato (inclui o sufixo do vendor,
   ex.: `-tem` para Temurin).
3. Maven e Gradle usam a versão estável do SDKMAN automaticamente — sem edição.

### Python (`03-python.sh`)
1. Veja versões instaláveis: `pyenv install --list | grep -E "^\s*3\."`.
   (Pode ser necessário atualizar o pyenv antes: `cd ~/.pyenv && git pull`.)
2. Atualize `PYTHON_VERSION`.
3. **Pacotes dos venvs** (`django`, `dataeng`): estão sem pino de versão, então
   pegam a mais recente compatível a cada execução. Para travar versões
   específicas (recomendado em equipe), troque, por exemplo, `django` por
   `django==5.1.*` nas listas de `pip install`. Considere também manter um
   `requirements.txt` por ambiente.

### Ruby (`04-ruby.sh`)
1. Atualize o ruby-build para enxergar versões novas:
   `cd ~/.rbenv/plugins/ruby-build && git pull`.
2. Veja as disponíveis: `rbenv install --list`.
3. Atualize `RUBY_VERSION` e, se quiser, `RAILS_VERSION`.

### Perl (`05-perl.sh`)
1. Veja as disponíveis: `perlbrew available`.
2. Atualize `PERL_VERSION` (formato `perl-5.XX.Y`).
3. Os módulos via `cpanm` pegam a última versão do CPAN — sem edição. Para
   travar, use `Modulo@versao` na lista do `cpanm`.

### Node (`06-node.sh`)
1. Confira o major LTS atual em https://nodejs.org (a linha marcada como LTS).
2. Atualize `NODE_VERSION` (só o major, ex.: `22`).
3. Atualize `NVM_VERSION` para a tag mais recente do nvm em
   https://github.com/nvm-sh/nvm/releases (formato `v0.40.x`).
4. Pacotes globais (`typescript`, `eslint`, etc.) usam a última versão — sem edição.

### Docker (`07-docker.sh`) e DBeaver (`08-dbeaver.sh`)
- **Nada a fixar.** Ambos usam o repositório APT oficial, que sempre entrega a
  versão estável mais recente. Para atualizar uma instalação existente:
  `sudo apt-get update && sudo apt-get upgrade`.
- Manutenção só é necessária se a **chave GPG** ou a **URL do repositório** do
  fornecedor mudar (raro). Nesse caso, ajuste as linhas que baixam a `.gpg`/`.asc`
  e a que escreve em `/etc/apt/sources.list.d/`.

### Hadoop (`09-hadoop.sh`)
1. Veja a versão estável em https://hadoop.apache.org/releases.html.
2. Atualize `HADOOP_VERSION`. A URL de download é montada a partir dela.
3. **Atenção ao mirror:** o script usa `dlcdn.apache.org`. Versões antigas saem
   do mirror principal e vão para o archive
   (`https://archive.apache.org/dist/hadoop/common/`). Se o download falhar com
   404, troque o host `MIRROR` no script para o archive.

### Spark (`10-spark.sh`)
1. Veja a versão e o "package type" em https://spark.apache.org/downloads.html.
2. Atualize `SPARK_VERSION`.
3. Atualize `HADOOP_PROFILE` para casar com o sufixo do binário disponível
   (ex.: `bin-hadoop3` → `HADOOP_PROFILE=3`). Se a nomenclatura mudar no futuro,
   ajuste a variável `PKG` que monta o nome do arquivo.
4. Mesmo cuidado do Hadoop quanto a **mirror x archive** em versões antigas.
5. O `pip install pyspark==${SPARK_VERSION}` acompanha a variável — confira se
   essa versão existe no PyPI; às vezes há defasagem de alguns dias após o release.

---

## 4. Checklist rápido ao atualizar uma versão

1. [ ] Conferi a versão na página oficial (seção 2).
2. [ ] Atualizei a variável no topo do script (ou vou passar por env var).
3. [ ] Se for Hadoop/Spark/Go: confirmei que a **URL de download** responde
       (`curl -fI <url>`).
4. [ ] Para Java/Python/Ruby/Perl/Node: confirmei que a versão aparece na
       listagem do gerenciador (`sdk list`, `pyenv install --list`,
       `rbenv install --list`, `perlbrew available`).
5. [ ] Rodei o script numa VM/container Ubuntu limpo.
6. [ ] Verifiquei a versão instalada (`go version`, `java -version`,
       `python --version`, etc.).
7. [ ] Atualizei a tabela de versões no `README.md` principal, se houver.

---

## 5. Dica: centralizar as versões (opcional)

Se for atualizar com frequência, dá para criar um arquivo `versions.env` e
carregá-lo antes de rodar, em vez de editar cada script:

```bash
# versions.env
export GO_VERSION=1.26.4
export JAVA_VERSION=21.0.5-tem
export PYTHON_VERSION=3.12.7
export RUBY_VERSION=3.3.6
export RAILS_VERSION=7.2
export PERL_VERSION=perl-5.40.0
export NODE_VERSION=22
export HADOOP_VERSION=3.4.1
export SPARK_VERSION=3.5.3
export HADOOP_PROFILE=3
```

```bash
# uso
source versions.env
./install.sh all
```

Como os scripts já leem essas variáveis com o padrão `${VAR:-default}`, elas têm
prioridade e nenhum arquivo precisa ser editado.

---

## 6. Quando o problema NÃO é a versão

Se um script quebrar mesmo com a versão certa, suspeite de:

- **URL/mirror mudou** (Hadoop, Spark, Go): teste com `curl -fI <url>`.
- **Chave GPG do repositório expirou ou rodou** (Docker, DBeaver): rebaixe a
  chave conforme o passo no script.
- **Codename do Ubuntu não suportado ainda** pelo repositório do fornecedor
  (acontece logo após o lançamento de uma versão nova do Ubuntu). Aguarde o
  fornecedor publicar suporte ou aponte temporariamente para o codename anterior.
- **Gerenciador desatualizado** (pyenv/rbenv/perlbrew não "enxerga" a versão
  nova): faça `git pull` no diretório do gerenciador antes.
