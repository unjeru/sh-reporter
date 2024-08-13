FROM clickhouse/clickhouse-server:24.7.3.42-alpine

RUN apk add curl
WORKDIR /app
RUN apk add --no-cache --upgrade jq bash coreutils && rm -rf /var/cache/apk/*

COPY report.sh .
RUN chmod +x report.sh

ENTRYPOINT ["sh", "-c", "/app/report.sh"]