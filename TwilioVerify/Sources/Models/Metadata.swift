//
//  Metadata.swift
//  TwilioVerify
//
//  Created by Sergio Fierro on 6/2/20.
//  Copyright © 2020 Twilio. All rights reserved.
//

import Foundation

public protocol Metadata {
  var page: Int { get }
  var pageSize: Int { get }
  var nextPageURL: String? { get }
  var key: String { get }
}
