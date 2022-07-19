#!/bin/bash

if [ "$ACTION" == backup ]; then
  (
    set -e
    PGPASSWORD=$DB_PASSWORD pg_dumpall -h $DB_HOST -U $DB_USERNAME -p $DB_PORT -l $DB_DATABASE \
    -f $EBS_VOLUME_MOUNT_PATH/$JENKINS_DB_BACKUP_NAME
    echo "pg_dumpall operation SUCCESSFULLY COMPLETED. Path to file is $DUMP_FILE"
    aws s3 cp $EBS_VOLUME_MOUNT_PATH/$JENKINS_DB_BACKUP_NAME $AWS_BUCKET/$RANCHER_CLUSTER_PROJECT_NAME/
    echo "AWS s3 cp operation of file $EBS_VOLUME_MOUNT_PATH/$JENKINS_DB_BACKUP_NAME to s3 $AWS_BUCKET/$RANCHER_CLUSTER_PROJECT_NAME/ bucket SUCCESSFULLY COMPLETED"
  )
  errorCode=$?
  if [ $errorCode -ne 0 ]; then
    echo "pg_dump operation FAILED (postgres backup aws s3 cp failed)"
    exit $errorCode
  fi
elif [ "$ACTION" == restore ]; then
  (
    set -e
    aws s3 cp $AWS_BUCKET/$JENKINS_DB_BACKUP_NAME $EBS_VOLUME_MOUNT_PATH/$JENKINS_DB_BACKUP_NAME
    echo "AWS s3 cp operation of file $AWS_BUCKET/$JENKINS_DB_BACKUP_NAME to $EBS_VOLUME_MOUNT_PATH path SUCCESSFULLY COMPLETED"
    PGPASSWORD=$DB_PASSWORD psql -h $DB_HOST -U $DB_USERNAME -p $DB_PORT < $EBS_VOLUME_MOUNT_PATH/$JENKINS_DB_BACKUP_NAME > /dev/null
    echo "psql restore operation SUCCESSFULLY COMPLETED. Path to file is $EBS_VOLUME_MOUNT_PATH/$JENKINS_DB_BACKUP_NAME"
    )
    errorCode=$?
    if [ $errorCode -ne 0 ]; then
      echo "psql restore operation FAILED (postgres restore aws s3 cp failed)"
      exit $errorCode
    fi
fi

