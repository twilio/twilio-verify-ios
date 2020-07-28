//
//  AccessTokenResponse.swift
//  TwilioVerifyDemo
//
//  Created by Santiago Avila on 6/25/20.
//  Copyright © 2020 Twilio. All rights reserved.
//

import Foundation

struct AccessTokenResponse: Codable {
  let token: String
  let serviceSid: String
  let identity: String
  let factorType: String
}
