#!/usr/bin/env sh

REPLICAS=4
BUCKET="registry"
VOLUME_NAME="${BUCKET}"
SERVICE_NAME="${BUCKET}"

MINIO_IP=$(ifconfig eth0| grep 'inet addr:'| cut -d: -f2 | awk '{ print $1}')
MINIO_PORT=9000
MINIO_PROTOCOL="http"
MINIO_ACCESS_KEY=$(cat .minio_access_key)
MINIO_SECRET_KEY=$(cat .minio_secret_key)
MINIO_ENDPOINT="${MINIO_PROTOCOL}://${MINIO_IP}:${MINIO_PORT}"
REGISTRY_HTTP_SECRET=$(openssl rand -hex 10)

docker plugin install minio/minfs

docker volume create -d minio/minfs \
  --name "${VOLUME_NAME}" \
  -o endpoint="${MINIO_ENDPOINT}" \
  -o access-key="${MINIO_ACCESS_KEY}" \
  -o secret-key="${MINIO_SECRET_KEY}" \
  -o bucket="${BUCKET}"

docker network create --driver overlay docker-registry

docker service create --name "${SERVICE_NAME}" --network docker-registry \
  --replicas "${REPLICAS}" --publish 5000:5000 \
  --mount type=volume,volume-driver=minio/minfs,source="${VOLUME_NAME}",destination=/var/lib/registry,volume-label="registry" \
  --env REGISTRY_HTTP_SECRET="${REGISTRY_SECRET}" \
  registry:2
