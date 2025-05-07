# 3.0.0 (2025-04-30)

### Features
- Allow factors migration by providing the flag allowIphoneMigration, for enabling users to migrate their factors to another iPhone or restore them during backup processes. (#218) ([1dda013](https://github.com/twilio/twilio-verify-ios/commit/1dda0132c3047603bd85765ae5adbb5f28bbd552))
- Support new Xcode and iOS versions (#226) ([9abf25e](https://github.com/twilio/twilio-verify-ios/commit/9abf25e5157160bd52245e71280dbd1ae15ab3e2))

### Building system
- Update CI config (#211) ([2e19a0c](https://github.com/twilio/twilio-verify-ios/commit/2e19a0c2642195c673a9a3333e6d5f631a19e9b1))
- Xcode 14 support ([ae1a210](https://github.com/twilio/twilio-verify-ios/commit/ae1a210ea45f3696272af37ef15197f4eb2e7d68))
- Fix vulnerabilities (#220) ([7bd8715](https://github.com/twilio/twilio-verify-ios/commit/7bd8715d886b5302b307bc92ec4b21b567e2e7d1))
- Xcode 15 support (#221) ([9ef308c](https://github.com/twilio/twilio-verify-ios/commit/9ef308c80687ca7c090b335231edc1db614914e4))
- Add Privacy Manifest (#223) ([0f0c2f8](https://github.com/twilio/twilio-verify-ios/commit/0f0c2f8b5980e9f91afd3a957104823c9c3c4689))
- Fix release process ([9b9ea30](https://github.com/twilio/twilio-verify-ios/commit/9b9ea306f1f8d81a9d6336598d0d6ac3af075398))
- Fix Github author for CI ([86d43dc](https://github.com/twilio/twilio-verify-ios/commit/86d43dcf61d392147f1316ec9e76291846e4382a))
- fix release process. ([643c340](https://github.com/twilio/twilio-verify-ios/commit/643c340feb5ff5f66e94298ac08896cff2ff8529))

### BREAKING CHANGES
- Dropped support for iOS 10 ([ae1a210](https://github.com/twilio/twilio-verify-ios/commit/ae1a210ea45f3696272af37ef15197f4eb2e7d68))
- Dropped support for iOS 11 ([9ef308c](https://github.com/twilio/twilio-verify-ios/commit/9ef308c80687ca7c090b335231edc1db614914e4))

Architecture | Compressed Size | Uncompressed Size
------------ | --------------- | -----------------
arm64        |       0.2 MB    | 0.5 MB


# 2.2.2 (2022-07-13)

### Bug fixes
- Add retry for keychain operations, preventing 25300 keychain error code ([4f021c7](https://github.com/twilio/twilio-verify-ios/commit/4f021c7d2a650b8b4bb999979256ff9d507a26f7))

Architecture | Compressed Size | Uncompressed Size
------------ | --------------- | -----------------
arm64        |       0.4 MB    | 1.1 MB


# 2.2.1 (2022-06-28)

### Bug fixes
- NSErrors removed and added new specific errors ([71a1130](https://github.com/twilio/twilio-verify-ios/commit/71a1130f98ce0be978a732db018a519c5ba921c9))

Architecture | Compressed Size | Uncompressed Size
------------ | --------------- | -----------------
arm64        |       0.4 MB    | 1.1 MB


# 2.2.0 (2022-06-22)

### Features
- Allow sending custom metadata when creating a factor ([4b6e296](https://github.com/twilio/twilio-verify-ios/commit/4b6e296ddf0120e6b04f0139f1f43c0ff4f0c724))

### Building system
- Update fastlane ([8b2c1fe](https://github.com/twilio/twilio-verify-ios/commit/8b2c1fe7ce8b3a6c85da77c36727a001d5eb3925))

Architecture | Compressed Size | Uncompressed Size
------------ | --------------- | -----------------
arm64        |       0.4 MB    | 1.1 MB


# 2.1.0 (2022-03-23)

### Features
- Improve input error to provide reason of failure ([75684e3](https://github.com/twilio/twilio-verify-ios/commit/75684e33fb43f5d97a9d49ea11c4ee5882efebe6))
- Support notification extension by providing a method to configure an access group for keychain access ([0307d47](https://github.com/twilio/twilio-verify-ios/commit/0307d478e851ddee7e698ae03678695d1c0f326c))

### Bug fixes
- Make NetworkProvider's models public to allow creating a custom provider ([3b745ca](https://github.com/twilio/twilio-verify-ios/commit/3b745caa903e8ca9d35b952c74d47fcd48b5ea78))

### Building system
- Update xcode version ([abab855](https://github.com/twilio/twilio-verify-ios/commit/abab855a08d472b3fcdc315273fbd170a83b1f97))
- Gemfile.lock to reduce vulnerabilities (#193) ([176db65](https://github.com/twilio/twilio-verify-ios/commit/176db651cd91d8758f48b58f5493bfbe05dae373))
- Update gemfile lock ([69f4566](https://github.com/twilio/twilio-verify-ios/commit/69f456604897ce4e3992d8e8866419719cf0532b))

### Documentation
- Setting up a Notification Extension ([3fd1807](https://github.com/twilio/twilio-verify-ios/commit/3fd18074e4143aca40898a0e5b1383230e8761d3))

Architecture | Compressed Size | Uncompressed Size
------------ | --------------- | -----------------
arm64        |       0.4 MB    | 1.1 MB


# 2.0.0 (2022-01-18)

### Bug fixes
- Clearing storage after reinstall will remove only factors. Previous implementation was removing all the keychain items on reinstall ([0cbb442](https://github.com/twilio/twilio-verify-ios/commit/0cbb44230c6bcc044ba9deccdd3acce5a8949052))
- Improved network error to get Verify API error (#178) ([e6ebbb3](https://github.com/twilio/twilio-verify-ios/commit/e6ebbb36a63537ac38d8cf4e23dbe40b5767582f))

### Documentation
- add contributing.md ([b9e2acf](https://github.com/twilio/twilio-verify-ios/commit/b9e2acfd0696f67d96b64e3a3d4cb66c9990153d))

### KNOWN ISSUE
- A reinstall using this version will not clear the SDK storage if the user did not update to this SDK version before the uninstall ([0cbb442](https://github.com/twilio/twilio-verify-ios/commit/0cbb44230c6bcc044ba9deccdd3acce5a8949052)). This may (not) be a concern depending on your implementation

Architecture | Compressed Size | Uncompressed Size
------------ | --------------- | -----------------
arm64        |       0.4 MB    | 1.0 MB


# 1.3.0 (2021-11-30)

### Features
- Support notification platform 'none' to allow not sending push token. Factors with notification platform 'none' will not receive push notifications for challenges and polling should be implemented to get pending challenges ([e40a267](https://github.com/twilio/twilio-verify-ios/commit/e40a2675c46c5712b9e4d9440261d93753dfc03f))

### Documentation
- Update documentation to use new sample backend ([bae60b8](https://github.com/twilio/twilio-verify-ios/commit/bae60b87df5ac32ea7fb3e14fc28caf6236352ab))
- Improve persisting factors after a reinstall documentation (#166) ([df16896](https://github.com/twilio/twilio-verify-ios/commit/df16896a4e0bed01f9212c0c08c4b148b81b00b5))

Architecture | Compressed Size | Uncompressed Size
------------ | --------------- | -----------------
arm64        |       0.4 MB    | 1.0 MB


# 1.2.0 (2021-09-20)

### Features
- Allow persisting factors after a reinstall ([0598808](https://github.com/twilio/twilio-verify-ios/commit/059880871a9d9c7ef97bf025e076e3af0e7e8db7))

Architecture | Compressed Size | Uncompressed Size
------------ | --------------- | -----------------
arm64        |       0.4 MB    | 0.9 MB


# 1.1.0 (2021-09-13)

### Features
- Ordering for challenge list ([86ddbba](https://github.com/twilio/twilio-verify-ios/commit/86ddbbadd51516bdd4853defb4606edefeba71c0))

Architecture | Compressed Size | Uncompressed Size
------------ | --------------- | -----------------
arm64        |       0.4 MB    | 0.9 MB


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
