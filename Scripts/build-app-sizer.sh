#!/bin/bash -e

source `dirname $0`/env.sh
pushd ${BASE_DIR}

echo "Building Verify AppSizer iOS"
APP_DIR="AppSizer"
APP_SCHEME="AppSizer"
PROJECT_FILE="AppSizer/AppSizer.xcodeproj/project.pbxproj"
SCHEME_FILE="AppSizer/AppSizer.xcodeproj/xcshareddata/xcschemes/AppSizer.xcscheme"
EXPORT_OPTIONS_PLIST="AppSizer/AppSizer/ExportOptions/dev.plist"

WORKSPACE=TwilioVerify.xcworkspace
ARCHIVE_PATH="${ARCHIVE_DIR}/${APP_SCHEME}.xcarchive"

BITCODE_MODE=marker
if [ "${CONFIGURATION}" = "Release" ]; then
  BITCODE_MODE=bitcode
fi

mkdir -p ${ARCHIVE_PATH}

xcodebuild \
  -workspace ${WORKSPACE} \
  -scheme ${APP_SCHEME} \
  -derivedDataPath ${DERIVED_DATA_DIR} \
  -configuration ${CONFIGURATION} \
  -sdk iphoneos \
  -parallelizeTargets \
  -archivePath "${ARCHIVE_PATH}" \
  ONLY_ACTIVE_ARCH=NO \
  BITCODE_GENERATION_MODE=${BITCODE_MODE} \
  archive

xcodebuild \
  -exportArchive \
  -archivePath "${ARCHIVE_PATH}" \
  -exportPath "${IPA_DIR}" \
  -exportOptionsPlist ${EXPORT_OPTIONS_PLIST}

# Generate the sizing report
./Scripts/env.rb ./Scripts/generate-size-report.rb

# Cat the output for visibility
cat "${SIZE_REPORT_DIR}/SizeImpact.md"

# If we are running in a CI environment, upload the size report to AWS
if [ "${TWILIO_CI}" = "true" ]; then

  mkdir -p "${ZIP_DIR}"

  pushd ${SIZE_REPORT_DIR}
    zip --quiet -r "${ZIP_DIR}/${CONFIGURATION}-SizeReport.zip" *
  popd

  aws s3 cp --quiet ${ZIP_DIR}/${CONFIGURATION}-SizeReport.zip $AWS_BUILD_URL/${CONFIGURATION}/

  # Put things back the way they were
  cp ${BACKUP_DIR}/project.pbxproj ${PROJECT_FILE}
  cp ${BACKUP_DIR}/${APP_SCHEME}.xcscheme ${SCHEME_FILE}
fi

popd