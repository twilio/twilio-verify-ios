#!/bin/bash
chmod +x "$0"
# Build Universal Framework
bundle exec fastlane export_release_xcframework

# Zip Framework
cd Products/xcframeworks/release
zip -r ~/Desktop/$1.framework.zip $1.xcframework
cp -r $1.xcframework ~/Desktop/
