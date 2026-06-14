# Docker Composes — Dev Setup

Arquivos `docker-compose.yml` prontos para subir serviços de desenvolvimento
local. Todos usam **Compose V2** (`docker compose`, com espaço), que é o que o
script `07-docker.sh` instala (pacote `docker-compose-plugin`).

> Verifique sua instalação com: `docker compose version`


## Stack: localstack

Emula serviços da AWS localmente com [LocalStack](https://localstack.cloud)
(edição Community, gratuita). Configurado para **SQS, SNS e S3**, que são
totalmente suportados na versão gratuita.

| Item                | Valor                                   |
|---------------------|-----------------------------------------|
| Imagem              | localstack/localstack:3                 |
| Endpoint (gateway)  | http://localhost:4566                   |
| Região padrão       | us-east-1                               |
| Persistência        | ativada (dados sobrevivem a reinícios)  |
| Health check        | http://localhost:4566/_localstack/health|

Todos os serviços usam o **mesmo endpoint** (`http://localhost:4566`) — não há
porta separada por serviço.

### Recursos de exemplo criados no boot

O script `localstack/init/01-create-resources.sh` roda automaticamente quando o
LocalStack fica pronto e já cria:
- bucket S3 `dev-bucket`
- fila SQS `dev-queue`
- tópico SNS `dev-topic`
- inscrição da fila no tópico (fan-out SNS → SQS)

Edite esse script para criar os recursos que o seu projeto precisa.

### Como usar (AWS CLI)

Com o AWS CLI instalado no host, aponte para o endpoint do LocalStack. As
credenciais podem ser quaisquer valores (o LocalStack não valida):

```bash
export AWS_ACCESS_KEY_ID=test
export AWS_SECRET_ACCESS_KEY=test
export AWS_DEFAULT_REGION=us-east-1
ENDPOINT="--endpoint-url http://localhost:4566"

# S3
aws $ENDPOINT s3 ls
aws $ENDPOINT s3 cp arquivo.txt s3://dev-bucket/

# SQS
aws $ENDPOINT sqs list-queues
aws $ENDPOINT sqs send-message \
  --queue-url http://localhost:4566/000000000000/dev-queue \
  --message-body "olá"

# SNS
aws $ENDPOINT sns list-topics
aws $ENDPOINT sns publish \
  --topic-arn arn:aws:sns:us-east-1:000000000000:dev-topic \
  --message "evento"
```

> Dentro de um container, use `http://localstack:4566` como endpoint em vez de
> `localhost`. Nos SDKs (boto3, AWS SDK for Java/JS, etc.), basta configurar o
> `endpoint_url` / `endpoint` apontando para o LocalStack.

Exemplo com boto3 (Python):

```python
import boto3
s3 = boto3.client("s3", endpoint_url="http://localhost:4566",
                  aws_access_key_id="test", aws_secret_access_key="test",
                  region_name="us-east-1")
print([b["Name"] for b in s3.list_buckets()["Buckets"]])
```

## Stack: all-in-one

Reúne os 13 serviços das stacks num único `docker-compose.yml`. Útil para
subir tudo de uma vez, mas **consome bastante RAM** (recomendável 8 GB+ livres).
Em máquinas modestas, prefira as stacks separadas ou suba serviços específicos
com `docker compose up -d <serviço> ...`.

### Alternativa: combinar arquivos com `-f`

Em vez do all-in-one, você também pode combinar os composes separados sem
duplicar nada, passando vários `-f`. Rode a partir da pasta `compose/`:

```bash
docker compose -f localstack/docker-compose.yml up -d
```

> Nesse modo, os caminhos relativos de `env_file` e volumes bind (como
> `hadoop.env` e `airflow/dags/`) são resolvidos a partir de cada arquivo, então
> funciona normalmente. O all-in-one existe só para conveniência de um comando único.

## Dicas e solução de problemas

- **Precisa de `sudo`?** Se você ainda não fez logout/login após rodar o
  `07-docker.sh`, seu usuário pode não estar ativo no grupo `docker` ainda. Faça
  logout/login ou rode `newgrp docker`.
- **Porta já em uso** (ex.: já tem um Postgres local na 5432): mude a porta no
  `.env` antes de subir (ex.: `POSTGRES_PORT=5433`).
- **Conflito com Hadoop/Spark instalados na máquina** (scripts 09/10): os serviços
  em container usam as mesmas portas (9870, 8080, 9000...). Não rode os dois ao
  mesmo tempo, ou ajuste as portas no `.env`.
- **Resetar um serviço do zero**: `docker compose down -v` apaga os volumes e,
  na próxima subida, tudo começa limpo.
- **Versões das imagens**: estão fixadas por tag (ex.: `postgres:16`). Para
  atualizar, troque a tag no `docker-compose.yml` e rode
  `docker compose pull && docker compose up -d`.
