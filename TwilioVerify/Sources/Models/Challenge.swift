//
//  Challenge.swift
//  TwilioVerify
//
//  Created by Sergio Fierro on 6/2/20.
//  Copyright © 2020 Twilio. All rights reserved.
//

import Foundation

public protocol Challenge {
  var sid: String { get }
  var challengeDetails: ChallengeDetails { get }
  var hiddenDetails: String { get }
  var factorSid: String { get }
  var status: ChallengeStatus { get }
  var createdAt: Date { get }
  var updatedAt: Date { get }
  var expirationDate: Date { get }
}

public enum ChallengeStatus: String, Codable {
  case pending
  case approved
  case denied
  case expired
}

public struct ChallengeDetails {
  public let message: String
  public let fields: [Detail]
  public let date: Date?
}

public struct Detail: Codable {
  public let label: String
  public let value: String
}
