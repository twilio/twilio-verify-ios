//
//  CacheStorage.swift
//  TwilioVerifyDemoCache
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

protocol CacheStorageProtocol {
    func delete(key: String)
    func getAll<T: Codable>() -> [T]
    func get<T: Codable>(key: String) -> T?
    func set<T: Codable>(key: String, value: T)
}

/**
 This class is meant for sharing data between
 the app and the notification extension.
 This class is not required for your SDK implementation.
 */
final class CacheStorage {
    // MARK: - Properties
    private lazy var jsonDecoder = JSONDecoder()
    private lazy var jsonEncoder = JSONEncoder()
    private lazy var provider = UserDefaults(
        suiteName: "group.twilio.TwilioVerifyDemo"
    )
}

// MARK: - DemoStorageProtocol
extension CacheStorage: CacheStorageProtocol {
    func getAll<T: Codable>() -> [T] {
        let allValues = provider?.dictionaryRepresentation().compactMap {
            $0.value as? Data
        } ?? []
        
        do {
            return try allValues.compactMap {
                try jsonDecoder.decode(T.self, from: $0)
            }
        } catch {
            print(error.localizedDescription)
            return []
        }
    }
    
    func get<T: Codable>(key: String) -> T? {
        guard let data = provider?.data(forKey: key) else {
            return nil
        }
        
        do {
            return try jsonDecoder.decode(T.self, from: data)
        } catch {
            print(error.localizedDescription)
            return nil
        }
    }
    
    func delete(key: String) {
        provider?.removeObject(forKey: key)
    }
    
    func set<T: Codable>(key: String, value: T) {
        do {
            let data = try jsonEncoder.encode(value)
            provider?.set(data, forKey: key)
        } catch {
            print(error.localizedDescription)
        }
    }
}
