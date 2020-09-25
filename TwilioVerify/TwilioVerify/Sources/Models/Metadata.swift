//
//  Metadata.swift
//  TwilioVerify
//
//  Copyright © 2020 Twilio. All rights reserved.
//  This file is licensed under the Apache License 2.0.
//  License text available at https://github.com/twilio/twilio-verify-ios/blob/main/LICENSE
//

import Foundation

///Describes the **Metadata** of a paginated service
public protocol Metadata {
  ///Current Page
  var page: Int { get }
  ///Number of result per page
  var pageSize: Int { get }
  ///Identifies the previous page
  var previousPageToken: String? { get }
  ///Identifies the next page
  var nextPageToken: String? { get }
}

//Describes the **Metadata** of the /Challenges service
struct ChallengeListMetadata: Metadata {
  ///Current Page
  let page: Int
  ///Number of result per page
  let pageSize: Int
  ///Identifies the previous page
  let previousPageToken: String?
  ///Identifies the next page
  let nextPageToken: String?
}
