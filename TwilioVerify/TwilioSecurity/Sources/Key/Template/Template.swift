//
//  Template.swift
//  TwilioSecurity
//
//  Copyright © 2020 Twilio. All rights reserved.
//  This file is licensed under the Apache License 2.0.
//  License text available at https://github.com/twilio/twilio-verify-ios/blob/main/LICENSE
//

import Foundation

///:nodoc:
public protocol Template {
  var alias: String {get}
  var algorithm: String {get}
  var shouldExist: Bool {get}
}

///:nodoc:
public protocol SignerTemplate: Template {
  var signatureAlgorithm: SecKeyAlgorithm {get}
  var parameters: [String: Any] {get}
  var accessControl: SecAccessControl {get}
}
