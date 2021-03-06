//
//  VerifyFactorPayload.swift
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

///Describes the information required to verify a **Factor**
public protocol VerifyFactorPayload {
  /// Factor sid
  var sid: String { get }
}

///Describes the information required to verify a **Factor** which type is **Push**
public struct VerifyPushFactorPayload: VerifyFactorPayload {
  /// Factor sid
  public let sid: String
  
  /**
  Creates a **VerifyPushFactorPayload** with the given parameters
  - Parameters:
    - sid: Factor sid
  */
  public init(sid: String) {
    self.sid = sid
  }
}
