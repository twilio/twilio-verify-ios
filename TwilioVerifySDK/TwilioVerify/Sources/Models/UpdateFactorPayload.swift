//
//  UpdateFactorPayload.swift
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

///Describes the information required to update a **Factor**
public protocol UpdateFactorPayload {
  ///Factor Sid
  var sid: String { get }
}

///Describes the information required to update a **Factor** which type is **Push**
public struct UpdatePushFactorPayload: UpdateFactorPayload {
  ///Factor Sid
  public let sid: String
  ///(Optional) Registration token generated by APNS when registering for remote notifications.
  ///Sending nil or empty will disable sending push notifications for challenges associated to this factor.
  public let pushToken: String?
  
  /**
  Creates an **UpdatePushFactorPayload** with the given parameters
  - Parameters:
    - sid: Factor Sid
    - pushToken: (Optional) Registration token generated by APNS when registering for remote notifications.
   Sending nil or empty will disable sending push notifications for challenges associated to this factor.
  */
  public init(sid: String, pushToken: String?) {
    self.sid = sid
    self.pushToken = pushToken
  }
}
