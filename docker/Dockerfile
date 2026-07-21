FROM 732722833398.dkr.ecr.us-west-2.amazonaws.com/postgresql:16.8.0

USER root

RUN apt update && apt install curl unzip jq -y \
    && curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" \
    && unzip awscliv2.zip && ./aws/install \
    && rm -rf /aws/ awscliv2.zip

COPY pg_dump_restore.sh /
RUN chmod +x /pg_dump_restore.sh && chown postgres:postgres /pg_dump_restore.sh

USER postgres
