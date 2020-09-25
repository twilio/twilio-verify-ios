//
//  HTTPHeaders.swift
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

struct HTTPHeaders {
  private var headers: [HTTPHeader] = []
  
  mutating func addAll(_ headers: [HTTPHeader]) {
    headers.forEach { add($0) }
  }
  
  private mutating func add(_ header: HTTPHeader) {
    update(header)
  }
  
  private mutating func update(_ header: HTTPHeader) {
    guard let index = headers.firstIndex(of: header) else {
      headers.append(header)
      return
    }
    
    headers.replaceSubrange(index...index, with: [header])
  }
  
  var dictionary: [String: String]? {
    let namesAndValues = headers.map { ($0.key, $0.value) }
    
    return Dictionary(namesAndValues, uniquingKeysWith: { _, last in last })
  }
}

struct HTTPHeader: Hashable {
  
  let key: String
  let value: String
  
  init(key: String, value: String) {
    self.key = key
    self.value = value
  }
}

extension HTTPHeader {
  
  static func accept(_ value: String) -> HTTPHeader {
    HTTPHeader(key: Constant.acceptType, value: value)
  }
  
  static func contentType(_ value: String) -> HTTPHeader {
    HTTPHeader(key: Constant.contentType, value: value)
  }
  
  static func userAgent(_ value: String) -> HTTPHeader {
    HTTPHeader(key: Constant.userAgent, value: value)
  }
  
  static func authorization(username: String, password: String) -> HTTPHeader {
    let credential = Data("\(username):\(password)".utf8).base64EncodedString()
    
    return authorization("\(Constant.basic) \(credential)")
  }
  
  static func authorization(bearerToken: String) -> HTTPHeader {
    authorization("\(Constant.basic) \(bearerToken)")
  }
  
  static func authorization(_ value: String) -> HTTPHeader {
    HTTPHeader(key: Constant.authorization, value: value)
  }
}

extension HTTPHeader {
  struct Constant {
    static let acceptType = "Accept"
    static let contentType = "Content-Type"
    static let userAgent = "User-Agent"
    static let basic = "Basic"
    static let bearer = "Bearer"
    static let authorization = "Authorization"
  }
}
