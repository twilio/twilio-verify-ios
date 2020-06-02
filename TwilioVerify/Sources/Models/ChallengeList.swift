//
//  ChallengeList.swift
//  TwilioVerify
//
//  Created by Sergio Fierro on 6/2/20.
//  Copyright © 2020 Twilio. All rights reserved.
//

import Foundation

public protocol ChallengeList {
  var challenges: [Challenge] { get }
  var metadata: Metadata { get }
}
