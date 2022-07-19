FROM bitnami/postgresql:12.8.0

USER root

RUN apt update && apt install curl unzip -y \
    && curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" \
    && unzip awscliv2.zip && ./aws/install \
    && rm -rf /aws/ awscliv2.zip

COPY pg_dump_restore.sh /
RUN chmod +x /pg_dump_restore.sh && chown 1001:1001 /pg_dump_restore.sh

# 1001 is postgres user id
USER 1001
