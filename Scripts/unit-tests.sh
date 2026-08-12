#!/bin/bash
chmod +x "$0"
bundle exec fastlane unit_tests test_plan:$1
