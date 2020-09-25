//
//  AccessTokenResponse.swift
//  TwilioVerifyDemo
//
//  Copyright © 2020 Twilio. All rights reserved.
//  This file is licensed under the Apache License 2.0.
//  License text available at https://github.com/twilio/twilio-verify-ios/blob/main/LICENSE
//

import Foundation

struct AccessTokenResponse: Codable {
  let token: String
  let serviceSid: String
  let identity: String
  let factorType: String
}
