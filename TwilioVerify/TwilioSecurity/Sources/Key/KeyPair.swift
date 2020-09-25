//
//  KeyPair.swift
//  TwilioSecurity
//
//  Copyright © 2020 Twilio. All rights reserved.
//  This file is licensed under the Apache License 2.0.
//  License text available at https://github.com/twilio/twilio-verify-ios/blob/main/LICENSE
//

import Foundation

struct KeyPair {
  var publicKey: SecKey
  var privateKey: SecKey
}
