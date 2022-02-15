//
//  StorageProvider.swift
//  TwilioVerifySDK
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

protocol StorageProvider {
  var version: Int { get }
  func save(_ data: Data, withKey key: String) throws
  func get(_ key: String) throws -> Data
  func removeValue(for key: String) throws
  func getAll() throws -> [Data]
  func clear() throws
}

extension StorageProvider {
  func value<Value: Decodable>(for key: String) -> Value? {
    guard let data = try? get(key) else { return nil }
    return try? JSONDecoder().decode(Value.self, from: data)
  }

  func value(for key: String) -> Bool? {
    guard let data = try? get(key) else { return nil }
    return Bool(String(decoding: data, as: UTF8.self))
  }

  func setValue<Value: Encodable>(_ value: Value, for key: String) {
    guard let data = try? JSONEncoder().encode(value) else { return }
    try? save(data, withKey: key)
  }

  func setValue(_ value: Bool, for key: String) {
    guard let data = value.description.data(using: .utf8) else { return }
    try? save(data, withKey: key)
  }
}
