//
//  Challenge.swift
//  TwilioVerify
//
//  Copyright © 2020 Twilio. All rights reserved.
//  This file is licensed under the Apache License 2.0.
//  License text available at https://github.com/twilio/twilio-verify-ios/blob/main/LICENSE
//

import Foundation

///Describes the information of a **Challenge**
public protocol Challenge {
  ///The unique SID identifier of the Challenge
  var sid: String { get }
  ///Details of the Challenge
  var challengeDetails: ChallengeDetails { get }
  ///Hidden details of the Challenge
  var hiddenDetails: String { get }
  ///Sid of the factor to which the Challenge is related
  var factorSid: String { get }
  ///Status of the Challenge
  var status: ChallengeStatus { get }
  ///Indicates the creation date of the Challenge
  var createdAt: Date { get }
  ///Indicates the last date the Challenge was updated
  var updatedAt: Date { get }
  ///Indicates the date in which the Challenge expires
  var expirationDate: Date { get }
}

///Describes the approval status of a **Challenge**
public enum ChallengeStatus: String, Codable {
  ///The Challenge is waiting to be approved or denied by the user
  case pending
  ///The Challenge was approved by the user
  case approved
  ///The Challenge was denied by the user
  case denied
  ///The Challenge expired and can't no longer be approved or denied by the user
  case expired
}

///Describes the Details of a **Challenge**
public struct ChallengeDetails {
  ///Associated message of the Challenge
  public let message: String
  ///Array with the additional details of a Challenge
  public let fields: [Detail]
  ///Date attached by the customer only received if the service has `includeDate` turned on
  public let date: Date?
}

///Describes the information of a **Challenge Detail**
public struct Detail: Codable {
  ///Detail's title
  public let label: String
  ///Detail's description
  public let value: String
}
