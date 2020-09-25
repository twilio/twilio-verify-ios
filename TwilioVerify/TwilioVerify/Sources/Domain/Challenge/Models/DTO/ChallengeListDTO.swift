//
//  ChallengesDTO.swift
//  TwilioVerify
//
//  Copyright © 2020 Twilio. All rights reserved.
//  This file is licensed under the Apache License 2.0.
//  License text available at https://github.com/twilio/twilio-verify-ios/blob/main/LICENSE
//

import Foundation

struct ChallengeListDTO: Codable {
  let challenges: [ChallengeDTO]
  let meta: MetadataDTO
}

struct MetadataDTO: Codable {
  let page: Int
  let pageSize: Int
  let previousPageURL: String?
  let nextPageURL: String?
  
  enum CodingKeys: String, CodingKey {
    case page
    case pageSize = "page_size"
    case previousPageURL = "previous_page_url"
    case nextPageURL = "next_page_url"
  }
}
