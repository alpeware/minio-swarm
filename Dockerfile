FROM minio/minio

ENV SERVICE "minio"
ENV VOLUME "export"

COPY entrypoint.sh /opt/usr/

ENTRYPOINT ["/opt/usr/entrypoint.sh"]
