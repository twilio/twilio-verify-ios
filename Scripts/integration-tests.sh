#!/bin/bash
chmod +x "$0"
bundle exec fastlane integration_tests test_plan:$1 device:"$2"
