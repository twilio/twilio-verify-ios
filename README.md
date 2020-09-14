# Twilio Verify iOS

[![CircleCI](https://circleci.com/gh/twilio/twilio-verify-ios.svg?style=shield&circle-token=278ebe32d8aac19f79d4f3b56edf2950d76f4d4c)](https://circleci.com/gh/twilio/twilio-verify-ios)
[![Carthage Compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
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
* [Errors](#Errors)
* [Update factor's push token](#UpdatePushToken)
* [Delete a factor](#DeleteFactor)

<a name='About'></a>

## About
Twilio Verify Push SDK helps you verify users by adding a low-friction, secure, cost-effective, "push verification" factor into your own mobile application. This fully managed API service allows you to seamlessly verify users in-app via a secure channel, without the risks, hassles or costs of One-Time Passcodes (OTPs).
This project provides an SDK to implement Verify Push for your iOS app.

<a name='Dependencies'></a>

## Dependencies

None

<a name='Requirements'></a>

## Requirements
* iOS 11+
* Swift 5.2
* Xcode 11.x

<a name='Documentation'></a>

## Documentation
[SDK API docs](https://twilio.github.io/twilio-verify-ios/latest/)

<a name='Installation'></a>

## Installation

### Add library

#### Carthage

To integrate TwilioVerify into your Xcode project using Carthage, specify it in your `Cartfile`:

```ogdl
github "twilio/twilio-verify-ios"
```

### Register Your App with APNs
If you want to receive challenges as push notifications, you should register Your App with APNs. More info [here](https://developer.apple.com/documentation/usernotifications/registering_your_app_with_apns)

<a name='Usage'></a>

## Usage

See [Verify Push Quickstart](https://www.twilio.com/docs/verify/quickstarts/push-ios) for a step-by-step guide to using this SDK in a basic Verify Push implementation.

<a name='SampleApp'></a>

## Running the Sample app

### To run the Sample App:
* Clone the repo
* Change the Bundle Identifier to something unique so Apple’s push notification server can direct pushes to this app
* [Enable push notifications](https://help.apple.com/xcode/mac/current/#/devdfd3d04a1)
* Get the Access token generation URL from your backend [(Running the Sample backend)](#SampleBackend). You will use it for creating a factor
* Run the `TwilioVerifyDemo` project using `Release` as build configuration

<a name='SampleBackend'></a>

## Running the Sample backend

* Clone this repo: https://github.com/twilio/verify-push-sample-backend
* Configure a [Notify Service](https://www.twilio.com/docs/verify/quickstarts/push-ios#configure-or-select-a-notify-service) for the sample app, using the same APNs configuration
* Configure a [Verify Service](https://www.twilio.com/docs/verify/quickstarts/push-ios#configure-a-verify-service), using the Notify service for the sample app
* Run the steps in the [README file](https://github.com/twilio/verify-push-sample-backend/blob/master/README.md)

<a name='UsingSampleApp'></a>

## Using the sample app

### Adding a factor
* Press Create factor in the factor list (click on the +, top right)
* Enter the identity to use. This value should be an UUID that identifies the user to prevent PII information use
* Enter the Access token URL (Access token generation URL, including the path, e.g. https://yourapp.ngrok.io/accessTokens)
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

<a name='Errors'></a>

## Errors
Types | Code | Description
---------- | ----------- | -----------
Network | 68001 | Exception while calling the API
Mapping | 68002 | Exception while mapping an entity
Storage | 68003 | Exception while storing/loading an entity
Input | 68004 | Exception while loading input
Key Storage | 68005 | Exception while storing/loading key pairs
Initialization | 68006 | Exception while initializing an object
Authentication Token | 68007 | Exception while generating token

<a name='UpdatePushToken'></a>

## Update factor's push token
You can update the factor's push token in case it changed, calling the `TwilioVerify.updateFactor` method:
```
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
```
twilioVerify.deleteFactor(withSid: factorSid, success: {
  // Success
}) { error in
  // Error
}
```
