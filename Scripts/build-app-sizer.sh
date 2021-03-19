#!/bin/bash
set -e

source `dirname $0`/env.sh
pushd ${BASE_DIR}

# Generate the sizing report
./Scripts/env.rb ./Scripts/generate-size-report.rb

# Cat the output for visibility
cat "${SIZE_REPORT_DIR}/SizeImpact.md"
popd
