#!/usr/bin/env sh

REPLICAS=4
PORT=9200
BUCKET="es"
VOLUME_NAME="${BUCKET}"
SERVICE_NAME="${BUCKET}"
NETWORK_NAME="${BUCKET}"

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

docker network create --driver overlay "${NETWORK_NAME}"

docker service create --name "${SERVICE_NAME}" --network "${NETWORK_NAME}" \
  --replicas "${REPLICAS}" --publish "${PORT}":"${PORT}" \
  --mount type=volume,volume-driver=minio/minfs,source="${VOLUME_NAME}",destination=/usr/share/elasticsearch/data,volume-label="elasticsearch" \
  --env "cluster.name=docker-cluster=${SERVICE_NAME}" \
  --env "bootstrap.memory_lock=true" \
  --env "ES_JAVA_OPTS=-Xms512m -Xmx512m" \
	--env "http.host=0.0.0.0"
  elasticsearch:5.2.1
