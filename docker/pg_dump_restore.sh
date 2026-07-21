#!/bin/bash
set -e

echo "=========================================="
echo "Action:         ${ACTION}"
echo "Backup name:    ${DB_BACKUP_NAME}"
echo "Bucket:         ${S3_BACKUPS_BUCKET}"
echo "Directory:      ${S3_BACKUPS_DIRECTORY}"
echo "Mount path:     ${EBS_VOLUME_MOUNT_PATH}"
echo "DB host:        ${DB_HOST}:${DB_PORT}"
echo "DB database:    ${DB_DATABASE}"
echo "=========================================="

SQL_FILE="${EBS_VOLUME_MOUNT_PATH}/${DB_BACKUP_NAME}.sql"
S3_PATH="s3://${S3_BACKUPS_BUCKET}/${S3_BACKUPS_DIRECTORY}/${DB_BACKUP_NAME}.sql"

if [ "$ACTION" = "backup" ]; then

  echo "[backup] Running pg_dump..."
  PGPASSWORD="${DB_PASSWORD}" pg_dump \
    -h "${DB_HOST}" \
    -U "${DB_USERNAME}" \
    -p "${DB_PORT}" \
    --dbname="${DB_DATABASE}" \
    --no-password \
    --format=plain \
    --file="${SQL_FILE}"

  echo "[backup] pg_dump completed successfully (size: $(wc -c < "${SQL_FILE}" | tr -d ' ') bytes)"

  echo "[backup] Uploading to S3: ${S3_PATH}"
  aws --region us-west-2 s3 cp "${SQL_FILE}" "${S3_PATH}"
  echo "[backup] Upload completed successfully"

  rm -f "${SQL_FILE}"
  echo "[backup] Done"

elif [ "$ACTION" = "restore" ]; then

  echo "[restore] Downloading from S3: ${S3_PATH}"
  aws --region us-west-2 s3 cp "${S3_PATH}" "${SQL_FILE}"
  echo "[restore] Download completed"

  echo "[restore] Running psql restore..."
  PGPASSWORD="${DB_PASSWORD}" psql \
    -h "${DB_HOST}" \
    -U "${DB_USERNAME}" \
    -p "${DB_PORT}" \
    --dbname="${DB_DATABASE}" \
    -f "${SQL_FILE}"

  echo "[restore] psql restore completed successfully"

  rm -f "${SQL_FILE}"
  echo "[restore] Done"

else
  echo "Unknown ACTION: '${ACTION}'. Must be 'backup' or 'restore'."
  exit 1
fi
