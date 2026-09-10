#!/bin/bash

DANGER_PARAMS="${1:?Usage: $0 <danger_params>}"

bundle exec danger $DANGER_PARAMS --verbose --remove-previous-comments
