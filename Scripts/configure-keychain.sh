#!/bin/sh

# Create a custom keychain
security create-keychain -p keychain_password ios-build.keychain

# Make the custom keychain default, so xcodebuild will use it for signing
security default-keychain -s ios-build.keychain

# Unlock the keychain
security unlock-keychain -p keychain_password ios-build.keychain

# Set keychain timeout to 10 minutes for long builds
# see http://www.egeek.me/2013/02/23/jenkins-and-xcode-user-interaction-is-not-allowed/
security set-keychain-settings -t 600
 -l ~/Library/Keychains/ios-build.keychain

# Add certificates to keychain and allow codesign to access them
security import ./temp/secrets/Certificates.p12 -k ~/Library/Keychains/ios-build.keychain -P $CERT_PASSWORD -A

security set-key-partition-list -S apple-tool:,apple: -k keychain_password ~/Library/Keychains/ios-build.keychain