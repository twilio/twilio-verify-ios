#!/bin/bash

cd ..
sdk_version=($(head -n 1 TwilioVerify/Config/Version.xcconfig))
version=${sdk_version[@]: -1}

jazzy \
  --output docs/$version/ \
  --theme apple

cd docs
ln -nsf "$version" latest 
