fastlane documentation
================
# Installation

Make sure you have the latest version of the Xcode command line tools installed:

```
xcode-select --install
```

Install _fastlane_ using
```
[sudo] gem install fastlane -NV
```
or alternatively using `brew install fastlane`

# Available Actions
## iOS
### ios unit_tests
```
fastlane ios unit_tests
```
Runs unit tests
### ios integration_tests
```
fastlane ios integration_tests
```
Runs integration tests
### ios build_universal_framework
```
fastlane ios build_universal_framework
```
Builds universal framework for release
### ios release
```
fastlane ios release
```
Release a new production version
### ios verify
```
fastlane ios verify
```
Verify next release
### ios increment_version
```
fastlane ios increment_version
```
Increment version
### ios public_api_docs
```
fastlane ios public_api_docs
```
Generates Public API Documentation
### ios post_release
```
fastlane ios post_release
```
Generates release tag, release notes and updates CHANGELOG.md
### ios danger_tests
```
fastlane ios danger_tests
```

### ios build_swift_package
```
fastlane ios build_swift_package
```


----

This README.md is auto-generated and will be re-generated every time [fastlane](https://fastlane.tools) is run.
More information about fastlane can be found on [fastlane.tools](https://fastlane.tools).
The documentation of fastlane can be found on [docs.fastlane.tools](https://docs.fastlane.tools).
