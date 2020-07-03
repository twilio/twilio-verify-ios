//
//  ChallengesDTO.swift
//  TwilioVerify
//
//  Created by Yeimi Moreno on 7/2/20.
//  Copyright © 2020 Twilio. All rights reserved.
//

import Foundation

struct ChallengeListDTO: Codable {
  let challenges: [ChallengeDTO]
  let meta: MetadataDTO
  
  enum CodingKeys: String, CodingKey {
    case challenges
    case meta
  }
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
