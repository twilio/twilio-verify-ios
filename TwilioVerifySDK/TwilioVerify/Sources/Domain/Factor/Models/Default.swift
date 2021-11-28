//
//  Default.swift
//  TwilioVerifySDK
//
//  Created by Yeimi Moreno on 11/28/21.
//  Copyright © 2021 Twilio. All rights reserved.
//

import Foundation

protocol DefaultValue {
  associatedtype Value: Codable
  static var defaultValue: Value { get }
}

@propertyWrapper
struct Default<T: DefaultValue> {
  var wrappedValue: T.Value
}

extension Default: Codable {
  init(from decoder: Decoder) throws {
    let container = try decoder.singleValueContainer()
    wrappedValue = (try? container.decode(T.Value.self)) ?? T.defaultValue
  }
}

extension KeyedDecodingContainer {
  func decode<T>(_ type: Default<T>.Type, forKey key: Key) throws -> Default<T> where T: DefaultValue {
    try decodeIfPresent(type, forKey: key) ?? Default(wrappedValue: T.defaultValue)
  }
}
