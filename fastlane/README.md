fastlane documentation
----

# Installation

Make sure you have the latest version of the Xcode command line tools installed:

```sh
xcode-select --install
```

For _fastlane_ installation instructions, see [Installing _fastlane_](https://docs.fastlane.tools/#installing-fastlane)

# Available Actions

## iOS

### ios unit_tests

```sh
[bundle exec] fastlane ios unit_tests
```

Runs unit tests

### ios integration_tests

```sh
[bundle exec] fastlane ios integration_tests
```

Runs integration tests

### ios build_universal_framework

```sh
[bundle exec] fastlane ios build_universal_framework
```

Builds universal framework for release

### ios export_release_xcframework

```sh
[bundle exec] fastlane ios export_release_xcframework
```

Export release xcframework

### ios build_app_sizer

```sh
[bundle exec] fastlane ios build_app_sizer
```

Runs app sizer

### ios release

```sh
[bundle exec] fastlane ios release
```

Release a new production version

### ios verify

```sh
[bundle exec] fastlane ios verify
```

Verify next release

### ios increment_version

```sh
[bundle exec] fastlane ios increment_version
```

Increment version

### ios public_api_docs

```sh
[bundle exec] fastlane ios public_api_docs
```

Generates Public API Documentation

### ios post_release

```sh
[bundle exec] fastlane ios post_release
```

Generates release tag, release notes and updates CHANGELOG.md

### ios danger_tests

```sh
[bundle exec] fastlane ios danger_tests
```



### ios build_swift_package

```sh
[bundle exec] fastlane ios build_swift_package
```



### ios distribute_debug_sample_app

```sh
[bundle exec] fastlane ios distribute_debug_sample_app
```

Distribute debug sample app for internal testing

### ios distribute_sample_app

```sh
[bundle exec] fastlane ios distribute_sample_app
```

Distribute sample app for internal testing

----

This README.md is auto-generated and will be re-generated every time [_fastlane_](https://fastlane.tools) is run.

More information about _fastlane_ can be found on [fastlane.tools](https://fastlane.tools).

The documentation of _fastlane_ can be found on [docs.fastlane.tools](https://docs.fastlane.tools).
