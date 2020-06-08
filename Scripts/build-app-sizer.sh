#!/bin/bash -e

source `dirname $0`/env.sh
pushd ${BASE_DIR}

echo "Building Video AppSizer iOS"
APP_DIR="AppSizer"
APP_SCHEME="AppSizer"
PROJECT_FILE="AppSizer/AppSizer.xcodeproj/project.pbxproj"
SCHEME_FILE="AppSizer/AppSizer.xcodeproj/xcshareddata/xcschemes/AppSizer.xcscheme"
EXPORT_OPTIONS_PLIST="AppSizer/AppSizer/ExportOptions/enterprise.plist"

if [ "${TWILIO_CI}" = "true" ]; then
# If we are running in a CI environment, we will need to download the framework and expand it before we can build.
  mkdir -p ${ZIP_DIR}
  aws s3 cp --quiet $AWS_BUILD_URL/${CONFIGURATION}/${CONFIGURATION}-universal-TwilioVideo.zip ${ZIP_DIR}
  mkdir -p ${UNIVERSAL_OUTPUTFOLDER}
  unzip -q -o ${ZIP_DIR}/${CONFIGURATION}-universal-TwilioVideo.zip -d ${UNIVERSAL_OUTPUTFOLDER}

  # And we need to alter some files a wee bit...
  BACKUP_DIR=${TEMP_DIR}/Backup/${APP_DIR}
  mkdir -p ${BACKUP_DIR}

  # Mangle the project file
  cp ${PROJECT_FILE} ${BACKUP_DIR}

  # 1. Use the universal framework we already built...
  sed -i "" "s:path = TwilioVideo.framework; sourceTree = BUILT_PRODUCTS_DIR; };:name = TwilioVideo.framework; path = \"${UNIVERSAL_OUTPUTFOLDER}/TwilioVideo.framework\"; sourceTree = \"<absolute>\"; };:g" ${PROJECT_FILE}

  # 2. Add it to the FRAMEWORK_SEARCH_PATHS
  sed -i "" "s:PRODUCT_BUNDLE_IDENTIFIER = com.twilio.video.AppSizer;:PRODUCT_BUNDLE_IDENTIFIER = com.twilio.video.AppSizer;\
				FRAMEWORK_SEARCH_PATHS = \"${UNIVERSAL_OUTPUTFOLDER}\";:g" ${PROJECT_FILE}

  # 3. If we are a debug build, disable BITCODE
  if [ "${CONFIGURATION}" = "Debug" ]; then
    sed -i "" 's/FRAMEWORK_SEARCH_PATHS/ENABLE_BITCODE = NO;\
				FRAMEWORK_SEARCH_PATHS/g' ${PROJECT_FILE}
  fi

  # Mangle the scheme file
  cp ${SCHEME_FILE} ${BACKUP_DIR}
  sed -E -i "" 's/buildImplicitDependencies = "YES"/buildImplicitDependencies = "NO"/g' ${SCHEME_FILE}
fi

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
  ${TWILIO_XCODE_QUIET_ON_CI} \
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
