# Twilio Verify iOS

[![CircleCI](https://circleci.com/gh/twilio/twilio-verify-ios.svg?style=shield&circle-token=278ebe32d8aac19f79d4f3b56edf2950d76f4d4c)](https://circleci.com/gh/twilio/twilio-verify-ios)
[![CocoaPods Compatible](https://img.shields.io/cocoapods/v/TwilioVerify.svg)](https://img.shields.io/cocoapods/v/TwilioVerify.svg)
[![Carthage Compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
[![Swift Package Manager Compatible](https://img.shields.io/badge/Swift_Package_Manager-compatible-4BC51D.svg?style=flat")](https://swift.org/package-manager/)
[![Platform](https://img.shields.io/cocoapods/p/TwilioVerify.svg?style=flat)](https://twilio.github.io/twilio-verify-ios/latest/)
[![Swift 5.2](https://img.shields.io/badge/Swift-5.2-orange.svg?style=flat)](https://developer.apple.com/swift/)
[![License](https://img.shields.io/badge/License-Apache%202-blue.svg?logo=law)](https://github.com/twilio/twilio-verify-ios/blob/main/LICENSE)



## Table of Contents

* [About](#About)
* [Dependencies](#Dependencies)
* [Requirements](#Requirements)
* [Documentation](#Documentation)
* [Installation](#Installation)
* [Usage](#Usage)
* [Running the Sample app](#SampleApp)
* [Running the sample backend](#SampleBackend)
* [Using the sample app](#UsingSampleApp)
* [Logging](#Logging)
* [Errors](#Errors)
* [Update factor's push token](#UpdatePushToken)
* [Delete a factor](#DeleteFactor)
* [Clear local storage](#ClearLocalStorage)
* [Reinstall and persist factors](#Reinstall)
* [Notification Extension](#NotificationExtension)
* [Contributing](#Contributing)
* [License](#License)

<a name='About'></a>

## About
Twilio Verify Push SDK helps you verify users by adding a low-friction, secure, cost-effective, "push verification" factor into your own mobile application. This fully managed API service allows you to seamlessly verify users in-app via a secure channel, without the risks, hassles or costs of One-Time Passcodes (OTPs).
This project provides an SDK to implement Verify Push for your iOS app.

<a name='Dependencies'></a>

## Dependencies

None

<a name='Requirements'></a>

## Requirements
* iOS 10+
* Swift 5.2
* Xcode 13.x

<a name='Documentation'></a>

## Documentation
[SDK API docs](https://twilio.github.io/twilio-verify-ios/latest/)

<a name='Installation'></a>

## Installation

### CocoaPods

[CocoaPods](https://cocoapods.org) is a dependency manager for Cocoa projects. For usage and installation instructions, visit their website. To integrate TwilioVerify into your Xcode project using CocoaPods, specify it in your `Podfile`:

```ruby
pod 'TwilioVerify', '~> 2.2.2'
```

### Carthage

[Carthage](https://github.com/Carthage/Carthage) is a decentralized dependency manager that builds your dependencies and provides you with binary frameworks. To integrate TwilioVerify into your Xcode project using Carthage, specify it in your `Cartfile`:

```ogdl
github "twilio/twilio-verify-ios" -> 2.2.2
```

Since version `2.2.2` of `TwilioVerifySDK` the prebuilt asset fat version `.framework` is been deprecated, to give space for the universal framework `.xcframework`. Make sure to use the new version of Carthage [0.38.0](https://github.com/Carthage/Carthage/releases/tag/0.38.0) that was release in order to support the `xcframework` assets, by using this version or a superior one, Carthage will download and unzip the `TwilioVerifySDK.framework.zip` attached in the release version, resulting in a `TwilioVerifySDK.xcframework` that can be found in the build folder of Carthage.

### Swift Package Manager

The [Swift Package Manager](https://swift.org/package-manager/) is a tool for automating the distribution of Swift code and is integrated into the `swift` compiler. It is in early development, but TwilioVerify does support its use on iOS.

Once you have your Swift package set up, adding TwilioVerify as a dependency is as easy as adding it to the `dependencies` value of your `Package.swift`.

```swift
dependencies: [
    .package(url: "https://github.com/twilio/twilio-verify-ios.git", .upToNextMajor(from: "2.2.2"))
]
```


### Register Your App with APNs
If you want to receive challenges as push notifications, you should register Your App with APNs. More info [here](https://developer.apple.com/documentation/usernotifications/registering_your_app_with_apns)

<a name='Usage'></a>

## Usage

---
**NOTE**

The SDK should be used from a Swift class.
See an example in the [TwilioVerifyAdapter class](https://github.com/twilio/twilio-verify-ios/blob/main/TwilioVerifyDemo/TwilioVerifyDemo/TwilioVerify/TwilioVerifyAdapter.swift)

Since version `2.2.2`, the target was changed from `TwilioVerify` to `TwilioVerifySDK`. Migrating from older versions will imply to update all the imports in your files, see an example in the [TwilioVerifyAdapter class](https://github.com/twilio/twilio-verify-ios/blob/main/TwilioVerifyDemo/TwilioVerifyDemo/TwilioVerify/TwilioVerifyAdapter.swift#L19)

---

See [Verify Push Quickstart](https://www.twilio.com/docs/verify/quickstarts/push-ios) for a step-by-step guide to using this SDK in a basic Verify Push implementation.

<a name='SampleApp'></a>

## Running the Sample app

### To run the Sample App:
* Clone the repo
* Change the Bundle Identifier to something unique so Apple’s push notification server can direct pushes to this app
* [Enable push notifications](https://help.apple.com/xcode/mac/current/#/devdfd3d04a1)
* Get the Access token generation URL from your backend [(Running the Sample backend)](#SampleBackend). You will use it for creating a factor
* Run the `TwilioVerifyDemo` project using `Release` as build configuration

#### Silently approve challenges

You can silently approve challenges when your app already knows that the user is trying to complete an action (actively logging in, making a transaction, etc.) on the same device as the registered device that is being challenged.

You can enable the option "Silently approve challenges" for a factor. After enabling it, every challenge received as a push notification when the app is in foreground for that factor will be silently approved, so user interaction is not required. The option will be saved for the session, so the selection will not be persisted.

<a name='SampleBackend'></a>

## Running the Sample backend

* Configure a [Push Credential](https://www.twilio.com/docs/verify/quickstarts/push-ios#create-a-push-credential) for the sample app, using the same APNs configuration
* Configure a [Verify Service](https://www.twilio.com/docs/verify/quickstarts/push-ios#create-a-verify-service-and-add-the-push-credential), using the Push Credential for the sample app
* Go to: https://www.twilio.com/code-exchange/verify-push-backend
* Use the `Quick Deploy to Twilio` option
  - You should log in to your Twilio account
  - Enter the Verify Service Sid you created above, you can find it [here](https://www.twilio.com/console/verify/services)
  - Deploy the application
  - Press `Go to live application`
  - You will see the start page. Copy the url and replace `index.html` with `access-token`.(e.g. https://verify-push-backend-xxxxx.twil.io/access-token). This will be your `Access Token generation URL`

<a name='UsingSampleApp'></a>

## Using the sample app

### Adding a factor
* Press Create factor in the factor list (click on the +, top right)
* Enter the identity to use. This value should be an UUID that identifies the user to prevent PII information use
* Enter the Access token URL (Access token generation URL, including the path, e.g. https://verify-push-backend-xxxxx.twil.io/access-token)
* Press Create factor
* Copy the factor Sid

### Sending a challenge
* Go to Create Push Challenge page (/challenge path in your sample backend)
* Enter the `identity` you used in factor creation
* Enter the `Factor Sid` you added
* Enter a `message`. You will see the message in the push notification and in the challenge view
* Enter details to the challenge. You will see them in the challenge view. You can add more details using the `Add more Details` button
* Press `Create challenge` button
* You will receive a push notification showing the challenge message in your device. 
* The app will show the challenge info below the factor information, in a `Challenge` section
* Approve or deny the challenge
* After the challenge is updated, you will see the challenge status in the backend's `Create Push Challenge` view

<a name='Logging'></a>
## Logging
By default, logging is disabled. To enable it you can either set your own logging services by implementing [LoggerService](https://github.com/twilio/twilio-verify-ios/blob/main/TwilioVerify/TwilioVerify/Sources/Logger/Logger.swift#L24) and calling `addLoggingService` (note that you can add as many logging services as you like) or enable the default logger service by calling `enableDefaultLoggingService`. Your multiple implementations and the default one can work at the same time, but you may just want to have it enabled during the development process, it's risky to have it turned on when releasing your app.
### Setting Log Level
You may want to log only certain processes that are happening in the SDK, or you just want to log it all, for that the SDK allows you to set a log level.
* error: reports behaviors that shouldn't be happening.
* info: warns specific information of what is being done.
* debug: detailed information.
* networking: specific data for the networking work, such as request body, headers, response code, response body.
* all: error, info, debug and networking are enabled.
### Usage
To start logging, enable the default logging service or/and pass your custom implementations
```swift
var builder = TwilioVerifyBuilder()
#if DEBUG
  builder = builder.enableDefaultLoggingService(withLevel: .all)
                   .addLoggingService(MyOwnLoggerService1())
                   .addLoggingService(MyOwnLoggerService2())
#endif
twilioVerify = try builder.build()
```

<a name='Errors'></a>

## Errors
Types | Code | Description
---------- | ----------- | -----------
Network | 60401 | Exception while calling the API
Mapping | 60402 | Exception while mapping an entity
Storage | 60403 | Exception while storing/loading an entity
Input | 60404 | Exception while loading input
Key Storage | 60405 | Exception while storing/loading key pairs
Initialization | 60406 | Exception while initializing an object
Authentication Token | 60407 | Exception while generating token

### Getting Verify API errors
You can control Verify API error codes listed [here](https://www.twilio.com/docs/api/errors) by following the next example:

```swift

twilioVerify.createFactor(withPayload: payload, success: { factor in
  // Success
}) { error in
  let apiError = error.originalError as? NetworkError
    
  if case let .failureStatusCode(response) = apiError {
    // Gets Verify API error response
    var errorResponse = response
    
    if let code = errorResponse.apiError?.code,
        let message = errorResponse.apiError?.message {
      print("Code: \(code) - \(message)")
    }
  }
}
```

Check an example [here](https://github.com/twilio/twilio-verify-ios/blob/main/TwilioVerifyDemo/TwilioVerifyDemo/CreateFactor/Presenter/CreateFactorPresenter.swift#L50)

### Getting the error cause
You can get the cause for an error accesing the associated error
```swift
twilioVerify.updateChallenge(withPayload: payload, success: {
  // Success
},failure: { error in
  if case .inputError(let detail) = error, let inputError = detail as? InputError {
    switch inputError {
      // Handle other cases here, in this example expired challenge case
      case .expiredChallenge: return
      default: return
    }
  }
})
```
You can find the associated errors for validations [here](https://github.com/twilio/twilio-verify-ios/blob/main/TwilioVerifySDK/TwilioVerify/Sources/TwilioVerifyError.swift#L119)


For extra detail, check specific internal operations errors [here](https://github.com/twilio/twilio-verify-ios/tree/main/TwilioVerifySDK/TwilioVerify/Sources/Errors/OperationErrors.swift#L27)

<a name='UpdatePushToken'></a>

## Update factor's push token
You can update the factor's push token in case it changed, calling the `TwilioVerify.updateFactor` method:
```swift
let updateFactorPayload = UpdatePushFactorPayload(sid: factorSid, pushToken: newPushToken)
twilioVerify.updateFactor(withPayload: payload, success: { factor in
  // Success
}) { error in
  // Error
}
```

See [FactorListPresenter](https://github.com/twilio/twilio-verify-ios/blob/main/TwilioVerifyDemo/TwilioVerifyDemo/FactorList/Presenter/FactorListPresenter.swift#L90) in the sample app. You should update the push token for all factors.

<a name='DeleteFactor'></a>

## Delete a factor
You can delete a factor calling the `TwilioVerify.deleteFactor` method:
```swift
twilioVerify.deleteFactor(withSid: factorSid, success: {
  // Success
}) { error in
  // Error
}
```

<a name='ClearLocalStorage'></a>

## Clear local storage
You can clear the local storage calling the `TwilioVerify.clearLocalStorage` method:
```swift
do {
  try twilioVerify.clearLocalStorage()
} catch {
  // Handle error
}
```
### Important Notes

- Calling this method will not delete factors in **Verify Push API**, so you need to delete them from your backend to prevent invalid/deleted factors when getting factors for an identity.
- Since the Keychain is used for storage this method can fail if there is an error while doing the Keychain operation.

<a name='Reinstall'></a>

## Reinstall and persist factors
By default, the created factors and key pairs will not persist in the device after the app is uninstalled and reinstalled for security reasons. However, it's possible to change this default behavior and persist the factors and key pairs after a reinstall, because both are saved in the keychain.

---
**NOTE**
This may change in future iOS versions, but it will keep working for iOS 15 and below. Preserving keychain items on app uninstall could be a security concern. You should not rely on this behaviour and provide an alternative way to enroll the factor again if this behaviour changes.

---

To persist factors after a reinstall, use `TwilioVerifyBuilder.setClearStorageOnReinstall` method when creating the `TwilioVerify` instance. The default value is `true`, so the factors will be deleted on reinstall. Change it to `false` to persist the factor(s)

```swift
let builder = TwilioVerifyBuilder().setClearStorageOnReinstall(false)
let twilioVerify = try builder.build()
```

The push token will change after the reinstall. Update the push token to receive push notifications for challenges, as is explained in [Update factor's push token](#UpdatePushToken)

The SDK is using [kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly](https://developer.apple.com/documentation/security/ksecattraccessibleafterfirstunlockthisdeviceonly) to [save factors and keypairs](https://github.com/twilio/twilio-verify-ios/blob/main/TwilioVerifySDK/TwilioSecurity/Sources/Keychain/KeychainQuery.swift#L63). According to Apple, 
> Items with this attribute do not migrate to a new device. Thus, after restoring from a backup of a different device, these items will not be present.

<a name='NotificationExtension'></a>

## Setting up a Notification Extension
The [Notification Extension](https://developer.apple.com/documentation/usernotifications/unnotificationserviceextension) is an App Extension that allows developers to modify or process the content of a remote notification before it is delivered to the user.

> Follow Apple's Modifying Content in Newly Delivered Notifications guide to create a Notification Extension.

To be able to use the Verify SDK in Notification Extensions, it is necessary to use [App Groups](https://developer.apple.com/documentation/security/keychain_services/keychain_items/sharing_access_to_keychain_items_among_a_collection_of_apps), this will allow the App Extension to be able to read the KeyChain storage from the application. Otherwise, the SDK will not be able to read any of the stored Factors or Challenges in the Notification Extension.

```swift
let builder = TwilioVerifyBuilder()
let twilioVerify = try builder.setAccessGroup("group.com.example.AppSuite").build()
```
> Use the **setAccessGroup** method to set up the app group used for keychain access.

Take into consideration that the Notification Extension only lives for a period of time of approximately 30 seconds, so if by some reason the App Extension does not process the remote notification content before that period expires, it will display the original content instead.

> See the [Notification Extension](https://github.com/twilio/twilio-verify-ios/tree/feature/notificationExtension) branch to check the example of an implementation using the Notification Extension & the SDK in the VerifyDemoApp.
---
**Sharing Factors using App Groups**

While setting up the **setAccessGroup** configuration for the first time, the factors data will migrate to use the **kSecAttrAccessGroup** Keychain's attribute. If the migration fails, error logs will be sent instead of throwing an error during initialization, the data will remain available for the main application but may not be available for App Extensions.

**Stop Sharing Factors from App Groups**

By removing the **App Group** from the **setAccessGroup** configuration, new factors will not be shared via the **Keychain** app groups. 

```swift
let builder = TwilioVerifyBuilder()
let twilioVerify = try builder.build()
```

To stop sharing existing factors created with **App Groups**, uncheck the **App Group** from the **App/App Extension** configuration in Xcode, as follow:

**App/App Extension** -> **App Groups** -> Uncheck **App Group**

> This will restrict access to the factors and will not affect the main application in which the data was initially created.

---
<a name='Contributing'></a>

## Contributing
This project welcomes contributions. Please check out our [Contributing guide](./CONTRIBUTING.md) to learn more on how to get started.

<a name='License'></a>

## License
[Apache © Twilio Inc.](./LICENSE)
