#!/usr/bin/env bash
set -euo pipefail

AWS_REGION="${AWS_REGION:-us-east-1}"
AWS_ACCOUNT_ID="${AWS_ACCOUNT_ID:-$(aws sts get-caller-identity --query Account --output text)}"
REGISTRY="${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com"
SRC="${SRC:-$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)}"

APPS=(
  "python:challenge/python-flask"
  "java:challenge/java-spring"
  "dotnet:challenge/dotnet-todoapi"
)

echo ">> Login no ECR"
aws ecr get-login-password --region "$AWS_REGION" \
  | docker login --username AWS --password-stdin "$REGISTRY"

for entry in "${APPS[@]}"; do
  dir="${entry%%:*}"; repo="${entry##*:}"
  echo ">> ${repo}  (${SRC}/${dir})"
  aws ecr describe-repositories --repository-names "$repo" --region "$AWS_REGION" >/dev/null 2>&1 \
    || aws ecr create-repository --repository-name "$repo" --region "$AWS_REGION" >/dev/null
  docker build --platform linux/amd64 -t "${REGISTRY}/${repo}:latest" "${SRC}/${dir}"
  docker push "${REGISTRY}/${repo}:latest"
done

echo ">> Pronto. Atualize as imagens em gitops/workloads/*/*.yaml para:"
echo "   ${REGISTRY}/challenge/<app>:latest"
