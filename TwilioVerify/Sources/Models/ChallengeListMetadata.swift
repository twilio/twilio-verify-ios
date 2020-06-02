//
//  ChallengeListMetadata.swift
//  TwilioVerify
//
//  Created by Sergio Fierro on 6/2/20.
//  Copyright © 2020 Twilio. All rights reserved.
//

import Foundation

struct ChallengeListMetadata: Metadata {
  let page: Int
  let pageSize: Int
  let nextPageURL: String?
  let key: String
  
  init(page: Int, pageSize: Int, nextPageURL: String?, key: String) {
    self.page = page
    self.pageSize = pageSize
    self.nextPageURL = nextPageURL
    self.key = key
  }
}
