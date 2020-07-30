#!/bin/bash -e

source `dirname $0`/env.sh
pushd ${BASE_DIR}

mkdir -p ~/Library/MobileDevice/Provisioning\ Profiles || true
cp ${SECRETS_DIR}/Provisioning\ Profiles/*.mobileprovision ~/Library/MobileDevice/Provisioning\ Profiles/

popd
