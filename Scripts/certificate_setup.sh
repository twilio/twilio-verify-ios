#!/bin/bash

set -e

COMMAND=$1
RAW_JOB_NAME=$2

if [[ -z "$RAW_JOB_NAME" ]]; then
  echo "Error: JOB_NAME argument is required."
  echo "Usage: $0 {setup|cleanup} <job_name>"
  exit 1
fi

# Sanitize job name: replace spaces and slashes with dashes
SANITIZED_JOB_NAME=$(echo "$RAW_JOB_NAME" | tr ' /' '--')

CERTIFICATE_PATH=$HOME/build_certificate_$SANITIZED_JOB_NAME.p12
PP_PATH=$HOME/profiles_$SANITIZED_JOB_NAME
mkdir -p $PP_PATH
KEYCHAIN_PATH=$HOME/app-signing-$SANITIZED_JOB_NAME.keychain-db

setup_certificates() {
    echo "Setting up Apple certificates and provisioning profiles for job: $JOB_NAME..."

    # Import certificate and provisioning profiles from CircleCI context
    echo -n "$VERIFY_DEMO_CERT" | base64 --decode -o $CERTIFICATE_PATH
    echo -n "$VERIFY_DEMO_PROFILE" | base64 --decode -o $PP_PATH/verify_demo.mobileprovision
    echo -n "$HOST_APP_PROFILE" | base64 --decode -o $PP_PATH/host_app.mobileprovision
    echo -n "$APP_SIZER_PROFILE" | base64 --decode -o $PP_PATH/app_sizer.mobileprovision

    # Create temporary keychain
    security create-keychain -p "$KEYCHAIN_PASS" $KEYCHAIN_PATH
    security set-keychain-settings -lut 21600 $KEYCHAIN_PATH
    security unlock-keychain -p "$KEYCHAIN_PASS" $KEYCHAIN_PATH

    # Import certificate
    security import $CERTIFICATE_PATH -P "$VERIFY_DEMO_CERT_PASS" -A -t cert -f pkcs12 -k $KEYCHAIN_PATH
    security set-key-partition-list -S apple-tool:,apple: -k "$KEYCHAIN_PASS" $KEYCHAIN_PATH
    security list-keychain -d user -s $KEYCHAIN_PATH

    # Apply provisioning profiles
    mkdir -p ~/Library/MobileDevice/Provisioning\ Profiles
    cp -a $PP_PATH/* ~/Library/MobileDevice/Provisioning\ Profiles
}

cleanup_signing() {
    echo "Cleaning up keychain and provisioning profile for job: $JOB_NAME..."
    security delete-keychain $KEYCHAIN_PATH || true
    rm -f $CERTIFICATE_PATH || true
    rm -rf $PP_PATH || true
}

case "$COMMAND" in
    setup)
        setup_certificates
        ;;
    cleanup)
        cleanup_signing
        ;;
    *)
        echo "Usage: $0 {setup|cleanup} <job_name>"
        exit 1
        ;;
esac