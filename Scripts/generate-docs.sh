#!/bin/bash

cd ..
marketing_version=($(head -n 1 TwilioVerify/Config/Version.xcconfig))
version=${marketing_version[@]: -1}

jazzy \
  --output docs/$version/ \
  --theme apple

cd docs
ln -nsf "$version" latest 
