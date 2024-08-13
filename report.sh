#!/bin/bash

# WA to avoid known issue with container based authorization in Fargate - START
CREDENTIALS=$(curl 169.254.170.2$AWS_CONTAINER_CREDENTIALS_RELATIVE_URI)

export AWS_ACCESS_KEY_ID=$(echo $CREDENTIALS | jq -r .AccessKeyId)
export AWS_SECRET_ACCESS_KEY=$(echo $CREDENTIALS | jq -r .SecretAccessKey)
export AWS_SESSION_TOKEN=$(echo $CREDENTIALS | jq -r .Token)

cat <<EOF > config.xml
<clickhouse>
    <s3>
        <access_key_id>${AWS_ACCESS_KEY_ID}</access_key_id>
        <secret_access_key>${AWS_SECRET_ACCESS_KEY}</secret_access_key>
        <session_token>${AWS_SESSION_TOKEN}</session_token>
    </s3>
</clickhouse>
EOF
# WA to avoid known issue with container based authorization in Fargate - END

TODAY=$(date +"%Y-%m-%d")
YDAY=$(date --date="1 day ago" +"%Y-%m-%d")
DAY2=$(date --date="2 day ago" +"%Y-%m-%d")
DAY3=$(date --date="3 day ago" +"%Y-%m-%d")

echo $TODAY
echo $YDAY
echo $DAY2
echo $DAY3

clickhouse local -C config.xml --logger.console  -n "SET max_threads=24; INSERT INTO FUNCTION s3('s3://burt-data-prod-us/yahoo/gam_log_files_fixed/Day="$TODAY"/report.parquet', 'Parquet') SETTINGS s3_truncate_on_insert = 1 select AdUnitId, AdvertiserId, OrderId, LineItemId, CreativeId, substring(dt, 25, 2) as Hour, count(AdUnitId) as Impressions from s3('s3://burt-data-prod-us/ocean/parquet/logs/account=YANDEX/network=22888152279/date=$TODAY/*/*Impressions*/log.parquet', 'Parquet') group by AdUnitId, AdvertiserId, OrderId, LineItemId, CreativeId, Hour;"
clickhouse local -C config.xml --logger.console  -n "SET max_threads=24; INSERT INTO FUNCTION s3('s3://burt-data-prod-us/yahoo/gam_log_files_fixed/Day="$YDAY"/report.parquet', 'Parquet') SETTINGS s3_truncate_on_insert = 1 select AdUnitId, AdvertiserId, OrderId, LineItemId, CreativeId, substring(dt, 25, 2) as Hour, count(AdUnitId) as Impressions from s3('s3://burt-data-prod-us/ocean/parquet/logs/account=YANDEX/network=22888152279/date=$TODAY/*/*Impressions*/log.parquet', 'Parquet') group by AdUnitId, AdvertiserId, OrderId, LineItemId, CreativeId, Hour;"
clickhouse local -C config.xml --logger.console  -n "SET max_threads=24; INSERT INTO FUNCTION s3('s3://burt-data-prod-us/yahoo/gam_log_files_fixed/Day="$DAY2"/report.parquet', 'Parquet') SETTINGS s3_truncate_on_insert = 1 select AdUnitId, AdvertiserId, OrderId, LineItemId, CreativeId, substring(dt, 25, 2) as Hour, count(AdUnitId) as Impressions from s3('s3://burt-data-prod-us/ocean/parquet/logs/account=YANDEX/network=22888152279/date=$TODAY/*/*Impressions*/log.parquet', 'Parquet') group by AdUnitId, AdvertiserId, OrderId, LineItemId, CreativeId, Hour;"
clickhouse local -C config.xml --logger.console  -n "SET max_threads=24; INSERT INTO FUNCTION s3('s3://burt-data-prod-us/yahoo/gam_log_files_fixed/Day="$DAY3"/report.parquet', 'Parquet') SETTINGS s3_truncate_on_insert = 1 select AdUnitId, AdvertiserId, OrderId, LineItemId, CreativeId, substring(dt, 25, 2) as Hour, count(AdUnitId) as Impressions from s3('s3://burt-data-prod-us/ocean/parquet/logs/account=YANDEX/network=22888152279/date=$TODAY/*/*Impressions*/log.parquet', 'Parquet') group by AdUnitId, AdvertiserId, OrderId, LineItemId, CreativeId, Hour;"
