#!/bin/bash
# Executado automaticamente pelo LocalStack quando ele fica "ready".
# Cria recursos de exemplo: 1 fila SQS, 1 tópico SNS, 1 bucket S3,
# e inscreve a fila no tópico (fan-out SNS -> SQS).
#
# Edite/adicione comandos conforme sua necessidade. O `awslocal` é um wrapper
# do AWS CLI já apontado para o endpoint do LocalStack (vem na imagem).

set -e

REGION="${AWS_DEFAULT_REGION:-us-east-1}"

echo "[init] Criando bucket S3 'dev-bucket'..."
awslocal s3 mb s3://dev-bucket || true

echo "[init] Criando fila SQS 'dev-queue'..."
QUEUE_URL=$(awslocal sqs create-queue --queue-name dev-queue --query 'QueueUrl' --output text)

echo "[init] Criando tópico SNS 'dev-topic'..."
TOPIC_ARN=$(awslocal sns create-topic --name dev-topic --query 'TopicArn' --output text)

echo "[init] Inscrevendo a fila no tópico (fan-out SNS -> SQS)..."
QUEUE_ARN=$(awslocal sqs get-queue-attributes \
  --queue-url "$QUEUE_URL" \
  --attribute-names QueueArn \
  --query 'Attributes.QueueArn' --output text)

awslocal sns subscribe \
  --topic-arn "$TOPIC_ARN" \
  --protocol sqs \
  --notification-endpoint "$QUEUE_ARN" || true

echo "[init] Recursos prontos:"
echo "       S3 bucket : dev-bucket"
echo "       SQS queue : $QUEUE_URL"
echo "       SNS topic : $TOPIC_ARN"
