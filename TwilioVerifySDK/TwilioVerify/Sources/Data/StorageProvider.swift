//
//  StorageProvider.swift
//  TwilioVerifySDK
//
//  Copyright © 2022 Twilio.
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

/// Workaround to store primitive data types below iOS 13 using Codable
private struct EncodableStruct<T>: Codable where T: Codable {
  let wrapped: T
}

extension StorageProvider {
  func value<Value: Codable>(for key: String) -> Value? {
    do {
      let data = try get(key)
      return try JSONDecoder().decode(EncodableStruct<Value>.self, from: data).wrapped
    } catch {
      Logger.shared.log(
        withLevel: .error,
        message: "Unable return value for key: \(key), due to error \(error)"
      )
      return nil
    }
  }

  func bool(for key: String) -> Bool? {
    do {
      let data = try get(key)
      return Bool(String(decoding: data, as: UTF8.self))
    } catch {
      Logger.shared.log(
        withLevel: .error,
        message: "Unable return value for key: \(key), due to error \(error)"
      )
      return nil
    }
  }

  func setValue<Value: Codable>(_ value: Value, for key: String) {
    do {
      let data = try JSONEncoder().encode(EncodableStruct(wrapped: value))
      try save(data, withKey: key)
    } catch {
      Logger.shared.log(
        withLevel: .error,
        message: "Unable to store value for key: \(key), due to error \(error)"
      )
    }
  }

  func setBool(_ bool: Bool?, for key: String) {
    do {
      guard
        let bool = bool,
        let data = bool.description.data(using: .utf8)
      else {
        return
      }
      try save(data, withKey: key)
    } catch {
      Logger.shared.log(
        withLevel: .error,
        message: "Unable to store value for key: \(key), due to error \(error)"
      )
    }
  }
}
