#!/bin/bash
chmod +x "$0"
bundle exec fastlane distribute_debug_sample_app env:$1 url:$2
