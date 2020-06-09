#!/bin/bash -e

source `dirname $0`/env.sh
pushd ${BASE_DIR}

function make_universal_framework() {
  if [ ! -d "${BUILD_DIR}/${CONFIGURATION}-iphoneos" ]; then
    return 0
  fi

  if [ ! -d "${BUILD_DIR}/${CONFIGURATION}-iphonesimulator" ]; then
    return 0
  fi

  FRAMEWORK_NAME=$1
  FRAMEWORK_PACKAGE="${FRAMEWORK_NAME}.framework"
  UUIDS=`dwarfdump --uuid "${BUILD_DIR}/${CONFIGURATION}-iphoneos/${FRAMEWORK_PACKAGE}/${FRAMEWORK_NAME}"`
  
  # Note: Important to use the iPhoneOS version of the framework as the basis as the Info.plist contains important values with respect to run-on-device capabililty
  cp -av "${BUILD_DIR}/${CONFIGURATION}-iphoneos/${FRAMEWORK_PACKAGE}" "${UNIVERSAL_OUTPUTFOLDER}/${FRAMEWORK_PACKAGE}/"

  lipo -create -output "${UNIVERSAL_OUTPUTFOLDER}/${FRAMEWORK_PACKAGE}/${FRAMEWORK_NAME}" \
               "${BUILD_DIR}/${CONFIGURATION}-iphoneos/${FRAMEWORK_PACKAGE}/${FRAMEWORK_NAME}" \
               "${BUILD_DIR}/${CONFIGURATION}-iphonesimulator/${FRAMEWORK_PACKAGE}/${FRAMEWORK_NAME}"

  if [ "${CONFIGURATION}" = "Release" ]; then
    echo Combine Device and Simulator .dSYM files into one
    cp -av "${BUILD_DIR}/${CONFIGURATION}-iphoneos/${FRAMEWORK_PACKAGE}.dSYM" "${UNIVERSAL_OUTPUTFOLDER}/${FRAMEWORK_PACKAGE}.dSYM/"

    lipo -create -output "${UNIVERSAL_OUTPUTFOLDER}/${FRAMEWORK_PACKAGE}.dSYM/Contents/Resources/DWARF/${FRAMEWORK_NAME}" \
                 "${BUILD_DIR}/${CONFIGURATION}-iphoneos/${FRAMEWORK_PACKAGE}.dSYM/Contents/Resources/DWARF/${FRAMEWORK_NAME}" \
                 "${BUILD_DIR}/${CONFIGURATION}-iphonesimulator/${FRAMEWORK_PACKAGE}.dSYM/Contents/Resources/DWARF/${FRAMEWORK_NAME}"

    # Collect the appropriate bcsymbolmap files
    for bcsymbolmap in `ls ${BUILD_DIR}/${CONFIGURATION}-iphoneos/*.bcsymbolmap`; do 
      UUID=`basename ${bcsymbolmap} .bcsymbolmap`

      if [ `echo "${UUIDS}" | grep ${UUID} | wc -l` -gt "0" ]; then
        mkdir -p "${UNIVERSAL_OUTPUTFOLDER}/${FRAMEWORK_PACKAGE}/BCSymbolMaps/"
        cp -av "${bcsymbolmap}" "${UNIVERSAL_OUTPUTFOLDER}/${FRAMEWORK_PACKAGE}/BCSymbolMaps/"
      fi
    done

    cp `dirname $0`/strip-frameworks.sh "${UNIVERSAL_OUTPUTFOLDER}/${FRAMEWORK_PACKAGE}/"
  fi
}

VERSION_INFO="TS_SDK_VERSION=${SDK_RELEASE_VERSION} TS_SDK_BUILD_NUMBER=${BUILD_NUMBER}"

# Output folder preparation
rm -rf ${BUILD_DIR}/${CONFIGURATION}*
rm -rf "${UNIVERSAL_OUTPUTFOLDER}"
mkdir -p "${UNIVERSAL_OUTPUTFOLDER}"

# determine bitcode generation mode. We only want full bitcode segments for release builds
BITCODE_MODE=marker
if [ "${CONFIGURATION}" = "Release" ]; then
  BITCODE_MODE=bitcode
fi


# Build the TwilioVideo target which does the framework, unit and integration tests
for framework in TwilioSecurity TwilioVerify; do
  for env in iphoneos iphonesimulator; do
    xcodebuild ${VERSION_INFO} \
      -workspace TwilioVerify.xcworkspace \
      -scheme ${framework} \
      -derivedDataPath ${DERIVED_DATA_DIR} \
      -configuration ${CONFIGURATION} \
      -sdk ${env} \
      -parallelizeTargets \
      ONLY_ACTIVE_ARCH=NO \
      BITCODE_GENERATION_MODE=${BITCODE_MODE}
  done
done


# Combine Device, Simulator .framework files into one
make_universal_framework TwilioSecurity
make_universal_framework TwilioVerify

popd