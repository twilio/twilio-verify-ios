#!/bin/bash
chmod +x "$0"
if [ -n "$2" ]; then
  bundle exec fastlane unit_tests test_plan:$1 device:"$2"
else
  bundle exec fastlane unit_tests test_plan:$1
fi
