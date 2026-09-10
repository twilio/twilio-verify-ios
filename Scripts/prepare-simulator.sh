#!/bin/bash
#
# Ensures a simulator with the exact given name exists on the newest installed
# iOS runtime, and prints the version-qualified device string ("Name (version)")
# on stdout so callers can pass it straight to `scan`.
#
# Why: fastlane's `scan` resolves a *bare* device name (e.g. "iPhone 17") through
# `default_os_version`, which parses `xcrun simctl runtime match list`. On CI
# runners that path can fail ("xcrun simctl runtime broken") when no simulator
# with that exact name exists. Passing a version-qualified device string that
# points at an existing simulator bypasses that fragile code path entirely.
#
# Usage: ./Scripts/prepare-simulator.sh "iPhone 17"
set -euo pipefail

DEVICE_NAME="${1:?Usage: $0 <device name>}"

# Resolve the newest available iOS runtime (identifier + version) using the Ruby
# that setup-ruby already provisioned, so we avoid depending on jq/python.
read -r RUNTIME_ID RUNTIME_VER < <(
  xcrun simctl list runtimes -j | ruby -rjson -e '
    runtimes = JSON.parse(STDIN.read)["runtimes"]
      .select { |r| r["platform"] == "iOS" && r["isAvailable"] }
      .sort_by { |r| r["version"].split(".").map(&:to_i) }
    r = runtimes.last
    abort("No available iOS simulator runtime found") unless r
    puts "#{r["identifier"]}\t#{r["version"]}"
  '
)

echo "Using iOS runtime ${RUNTIME_VER} (${RUNTIME_ID})" >&2

# Create the device if a simulator with this exact name does not already exist.
if ! xcrun simctl list devices | grep -qF "${DEVICE_NAME} ("; then
  echo "Creating simulator '${DEVICE_NAME}' on iOS ${RUNTIME_VER}..." >&2
  xcrun simctl create "${DEVICE_NAME}" "${DEVICE_NAME}" "${RUNTIME_ID}" >&2
else
  echo "Simulator '${DEVICE_NAME}' already exists." >&2
fi

# Emit the version-qualified device string for `scan` on stdout.
echo "${DEVICE_NAME} (${RUNTIME_VER})"
