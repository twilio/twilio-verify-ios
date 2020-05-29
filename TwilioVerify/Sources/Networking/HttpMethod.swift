//
//  HttpMethod.swift
//  TwilioVerify
//
//  Created by Sergio Fierro on 5/29/20.
//  Copyright © 2020 Twilio. All rights reserved.
//

import Foundation

struct HttpMethod: RawRepresentable, Equatable, Hashable {
  
  static let get = HttpMethod(rawValue: "GET")
  static let post = HttpMethod(rawValue: "POST")
  static let delete = HttpMethod(rawValue: "DELETE")
  static let put = HttpMethod(rawValue: "PUT")
  
  public let rawValue: String
  
  init(rawValue: String) {
    self.rawValue = rawValue
  }
}
//enum HttpMethod {
//
//  case get("GET")
//  case post("POST")
//  case delete("DELETE")
//  case put("PUT")
//}
