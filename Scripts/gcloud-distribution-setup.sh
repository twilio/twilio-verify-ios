#!/bin/bash
chmod +x "$0"
echo $GCLOUD_APP_DISTRIBUTION_SERVICE_KEY | base64 --decode > ${HOME}/gcloud-app-distribution-service-key.json
