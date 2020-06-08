#!/bin/bash -e

source `dirname $0`/env.sh
pushd ${BASE_DIR}

# Prepare the temp secret folder
mkdir -p ${SECRETS_DIR} || true

# Xcode signing certificates
echo $CERT_P12 | base64 -D -o ${SECRETS_DIR}/Certificates.p12

# Extract Provisioning profiles
openssl aes-256-cbc -K $PROVISIONING_PROFILES_KEY -iv $PROVISIONING_PROFILES_IV -in Provisioning\ Profiles.tar.enc -out ${SECRETS_DIR}/Provisioning\ Profiles.tar -d
pushd ${SECRETS_DIR}
  tar -xvf Provisioning\ Profiles.tar 
popd

# # Circle CI Testing Credentials
# echo $TEST_CREDENTIALS_CI | base64 -D -o ${SECRETS_DIR}/video-ios-credentials-circleci.plist

# # FTL Testing Credentials
# echo $TEST_CREDENTIALS_FTL | base64 -D -o ${SECRETS_DIR}/video-ios-credentials-ftl.plist

popd
