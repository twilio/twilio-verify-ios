//
//  FactorPayload.swift
//  TwilioVerify
//
//  Copyright © 2020 Twilio.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

import Foundation

protocol FactorDataPayload {
  var friendlyName: String { get }
  var type: FactorType { get }
  var serviceSid: String { get }
  var identity: String { get }
  var config: [String: String] { get }
}

struct CreateFactorPayload: FactorDataPayload {
  let friendlyName: String
  let type: FactorType
  let serviceSid: String
  let identity: String
  let config: [String: String]
  let binding: [String: String]
  let accessToken: String
  let metadata: [String: String]?
}

struct UpdateFactorDataPayload: FactorDataPayload {
  let friendlyName: String
  let type: FactorType
  let serviceSid: String
  let identity: String
  let config: [String: String]
  let factorSid: String
}
