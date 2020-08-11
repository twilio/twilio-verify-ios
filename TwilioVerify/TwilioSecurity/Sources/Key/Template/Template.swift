//
//  Template.swift
//  TwilioSecurity
//
//  Created by Santiago Avila on 5/18/20.
//  Copyright © 2020 Twilio. All rights reserved.
//

import Foundation

///:nodoc:
public protocol Template {
  var alias: String {get}
  var algorithm: String {get}
  var shouldExist: Bool {get}
}

///:nodoc:
public protocol SignerTemplate: Template {
  var signatureAlgorithm: SecKeyAlgorithm {get}
  var parameters: [String: Any] {get}
  var accessControl: SecAccessControl {get}
}
