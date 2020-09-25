//
//  ChallengesDTO.swift
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
