#!/bin/bash -e

# Global exports
export PATH=/usr/local/bin:$PATH
export LANG=en_US.UTF-8;

pushd `dirname ${BASH_SOURCE[0]}`/..
  export BASE_DIR="$(pwd)"
popd

# ARTIFACT DATA
# Parameters to distribute-to-cdn.sh
export TWILIO_VERIFY="TwilioVerify"
export TWILIO_SECURITY="TwilioSecurity"
export TWILIO_VERIFY_PACKAGE="${TWILIO_VERIFY}.framework"
export TWILIO_SECURITY_PACKAGE="${TWILIO_SECURITY}.framework"

export GROUP_ID="com.twilio.sdk"
export ARTIFACT_PLATFORM="ios"
export ARTIFACT_NAME="video"
export ARTIFACT_ID="twilio-${ARTIFACT_NAME}-${ARTIFACT_PLATFORM}"

export INTERNAL_ARTIFACT_ID="${ARTIFACT_ID}-internal"
export INTERNAL_ARTIFACT_FORMAT="tar.bz2"

export PUBLIC_ARTIFACT_ID="${FRAMEWORK_PACKAGE}"
export PUBLIC_ARTIFACT_FORMAT="zip"

export PUBLIC_STATIC_ARTIFACT_ID="lib${FRAMEWORK_NAME}"
export PUBLIC_STATIC_ARTIFACT_FORMAT="zip"

# Output locations
export TEMP_DIR="${BASE_DIR}/temp"
export SECRETS_DIR="${TEMP_DIR}/secrets"
export ZIP_DIR="${TEMP_DIR}/Zips"
export DERIVED_DATA_DIR="${TEMP_DIR}/DerivedData"
export BUILD_DIR="${DERIVED_DATA_DIR}/Build/Products"
export UNIVERSAL_OUTPUTFOLDER="${BUILD_DIR}/${CONFIGURATION}-universal"
export ARCHIVE_DIR="${TEMP_DIR}/Archives"
export IPA_DIR="${TEMP_DIR}/IPAs"
export SIZE_REPORT_DIR="${TEMP_DIR}/SizeReport"
export PACKAGE_ROOT_DIR="${TEMP_DIR}/Package"
