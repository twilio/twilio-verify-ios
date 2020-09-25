//
//  Metadata.swift
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
