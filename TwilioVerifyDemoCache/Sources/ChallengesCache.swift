//
//  ChallengesCache.swift
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

/**
 This class is meant for sharing data between
 the app and the notification extension.
 This class is not required for your SDK implementation.
 */
public class ChallengesCache {
    private static let cacheStorage: CacheStorageProtocol = CacheStorage()
    
    private init() {}
    
    public static var storedChallenges: [AppChallenge] {
        cacheStorage.getAll()
    }
    
    public static func save(challenge: AppChallenge) {
        cacheStorage.set(key: challenge.sid, value: challenge)
    }
    
    public static func deleteStoredChallenge(_ challenge: AppChallenge) {
        cacheStorage.delete(key: challenge.sid)
    }
}
