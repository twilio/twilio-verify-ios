#!/bin/bash
chmod +x "$0"
cp -a ~/Desktop/. ./AppSizer/AppSizer/Frameworks
ls -al ./AppSizer/AppSizer/Frameworks/
bundle exec fastlane build_app_sizer
cp ./temp/SizeReport/SizeImpact.md ~/Desktop
