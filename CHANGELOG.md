# 1.0.0 (2021-07-26)

### Features
- XCFramework Support & SDK Renaming (#141) ([4c62d70](https://github.com/twilio/twilio-verify-ios/commit/4c62d70eb48fa2ec63b1f1c72ab39d46c4708395))

### Bug fixes
- Update error codes (#133) ([c11b0fa](https://github.com/twilio/twilio-verify-ios/commit/c11b0fafa961b62ea57343fa4bc1a95aef8b6324))

### BREAKING CHANGES
- Supporting XCFramework & Renaming TwilioVerify framework to TwilioVerifySDK to prevent bug https://bugs.swift.org/browse/SR-14195 ([4c62d70](https://github.com/twilio/twilio-verify-ios/commit/4c62d70eb48fa2ec63b1f1c72ab39d46c4708395))

Architecture | Compressed Size | Uncompressed Size
------------ | --------------- | -----------------
arm64        |       0.4 MB    | 0.9 MB


# 0.4.0 (2021-03-05)

### Features
- SDK Logging (#124) ([d66887d](https://github.com/twilio/twilio-verify-ios/commit/d66887d293bacdd8aa7e7da8a47f373fa95f2c9d))

Architecture | Compressed Size | Uncompressed Size
------------ | --------------- | -----------------
arm64        |       0.4 MB    | 0.9 MB


# 0.3.2 (2021-02-02)

### Bug fixes
- Read SDK version and config ([d694f3e](https://github.com/twilio/twilio-verify-ios/commit/d694f3eef0a9bdc72614cee06377243d254175bb))

### Building system
- Add SDK as package dependency in sample app (#120) ([6da3f06](https://github.com/twilio/twilio-verify-ios/commit/6da3f069cd2e2666b83d99ff75aad3f807d09113))

Architecture | Compressed Size | Uncompressed Size
------------ | --------------- | -----------------
arm64        |       0.3 MB    | 0.8 MB


# 0.3.1 (2021-01-25)

### Bug fixes
- Fix version file and generation ([ee63023](https://github.com/twilio/twilio-verify-ios/commit/ee63023a80804295fda9b0c5778789e4301bdc59))

Architecture | Compressed Size | Uncompressed Size
------------ | --------------- | -----------------
arm64        |       0.3 MB    | 0.8 MB


# 0.3.0 (2021-01-25)

### Features
- Support react native bridge (#114) ([457b3a2](https://github.com/twilio/twilio-verify-ios/commit/457b3a297f062a299aa9432c7386485d24378721))

### Documentation
- Add note in readme about using the SDK from a swift class (#116) ([41ef89e](https://github.com/twilio/twilio-verify-ios/commit/41ef89e5a8017de4efe00e43a9d9c0e5b644b1e3))

Architecture | Compressed Size | Uncompressed Size
------------ | --------------- | -----------------
arm64        |       0.3 MB    | 0.8 MB


# 0.2.0 (2020-11-06)

### Features
- Add public method to clear local storage  (#107) ([5524ed2](https://github.com/twilio/twilio-verify-ios/commit/5524ed26f0dfd10bc13ce4bc2e784a804ef22665))

### Bug fixes
- Added support for iOS 10 ([d9fb78f](https://github.com/twilio/twilio-verify-ios/commit/d9fb78f482151eb19358503b79a9decace3659e9))

### Building system
- Fix Cocoapods release (#101) ([b5b9ee5](https://github.com/twilio/twilio-verify-ios/commit/b5b9ee54e5539a5d06658048e6102e2ba4e05680))
- Rearranged fastfile steps to match github tag with latest commit in main (#104) ([790aa52](https://github.com/twilio/twilio-verify-ios/commit/790aa52cd13d82069c573b1408d8cef979ace239))
- Fixed DemoApp compilation (#105) ([fc96eac](https://github.com/twilio/twilio-verify-ios/commit/fc96eacab91914fe78885205b825a3709c92ed60))
- Fixed DemoApp compilation (#106) ([755f955](https://github.com/twilio/twilio-verify-ios/commit/755f955b100bd598db4ec091ab5bcafcfdb6bec7))

Architecture | Compressed Size | Uncompressed Size
------------ | --------------- | -----------------
arm64        |       0.3 MB    | 0.8 MB


# 0.1.1 (2020-10-15)

### Bug fixes
- Added support for iOS 10 ([9549956](https://github.com/twilio/twilio-verify-ios/commit/95499567b5e5af68160dd78a2f720cece1b40a84))

Architecture | Compressed Size | Uncompressed Size
------------ | --------------- | -----------------
arm64        |       0.3 MB    | 0.8 MB


# 0.1.0 (2020-10-13)

### Features
- SPM and Cocoapods ([9fa6e45](https://github.com/twilio/twilio-verify-ios/commit/9fa6e45a07c7fad2536cbf69ea0186a0fe34a22b))

### Bug fixes
- Delete factor should delete it locally for deleted factors from API ([bfffa2f](https://github.com/twilio/twilio-verify-ios/commit/bfffa2fee0f0d9bb2b60aaba3e04c8964f4fb59a))
- Support new challenge format (#97) ([c7a8a71](https://github.com/twilio/twilio-verify-ios/commit/c7a8a71ea85a0baf17a153bb3be60644d7daa4ba))

### Code refactoring
- Create factor body params ([5b1a79e](https://github.com/twilio/twilio-verify-ios/commit/5b1a79e43cbc64515258164987aa20be2b6a7fed))
- Update factor body params ([8196548](https://github.com/twilio/twilio-verify-ios/commit/8196548c2c2a2309fb08d25d39d943842b5bcf32))

### Building system
- Added github issue templates and code of conduct ([c00b331](https://github.com/twilio/twilio-verify-ios/commit/c00b33197bef7875ea9f260ba8184b14867461e6))
- Change overall coverage to 70 ([5cdf81e](https://github.com/twilio/twilio-verify-ios/commit/5cdf81e022bdbcd27325b2e0e83531986f0dea4e))
- Update coverage to 70 ([694c88f](https://github.com/twilio/twilio-verify-ios/commit/694c88f2e90d252d28b9e288975c92d99ffcc6c1))

### Documentation
- Add SDK API docs link, update factor's push token and delete factor sections in readme ([ec0467e](https://github.com/twilio/twilio-verify-ios/commit/ec0467e4590b944b7e713ed6dfd8e4725eae12c0))

Architecture | Compressed Size | Uncompressed Size
------------ | --------------- | -----------------
arm64        |       0.1 MB    | 0.4 MB


# 0.0.4

### Features
- Storage migration

### Documentation
- `TwilioVerifyBuilder.build()` could throw an exception

# 0.0.3

### Documentation
- Code documentation

# 0.0.2

### Code refactoring
- More descriptive error description for `TwilioVerifyError`

# 0.0.1

### Features
- Version 0.0.1