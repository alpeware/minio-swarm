
One-shot script to setup a 4 node cluster

- go to http://play-with-docker.com
- copy paste below command
- open the link to port 9000 (blue next to node's IP)
- login using the credentials in the console

```
# git clone https://github.com/alpeware/minio-swarm.git && \
  cd minio-swarm && \
  ./minio-swarm.sh 4 && \
  echo "Access Key:" &&\
  cat .minio_access_key && \
  echo "Secret Key:" && \
  cat .minio_secret_key
```
