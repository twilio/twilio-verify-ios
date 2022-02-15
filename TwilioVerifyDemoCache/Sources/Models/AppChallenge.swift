//
//  AppChallenge.swift
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
 This struct is meant for sharing data between
 the app and the notification extension.
 This class is not required for your SDK implementation.
 */
public struct AppChallenge: Codable {
    public let sid: String
    public let challengeDetails: AppChallengeDetails
    public let hiddenDetails: [String: String]?
    public let factorSid: String
    public let status: AppChallengeStatus
    public let updatedAt: Date
    public let expirationDate: Date
    
    public init(
        sid: String,
        challengeDetails: AppChallengeDetails,
        hiddenDetails: [String: String]?,
        factorSid: String,
        status: AppChallengeStatus,
        updatedAt: Date,
        expirationDate: Date
    ) {
        self.sid = sid
        self.challengeDetails = challengeDetails
        self.hiddenDetails = hiddenDetails
        self.factorSid = factorSid
        self.status = status
        self.updatedAt = updatedAt
        self.expirationDate = expirationDate
    }
}

public enum AppChallengeStatus: String, Codable {
    case pending
    case approved
    case denied
    case expired
    case undefined
}

public struct AppChallengeDetails: Codable {
    public let message: String
    public let fields: [AppChallengeDetailField]
    
    public init(
        message: String,
        fields: [AppChallengeDetailField]
    ) {
        self.message = message
        self.fields = fields
    }
}

public struct AppChallengeDetailField: Codable {
    public let label: String
    public let value: String
    
    public init(label: String, value: String) {
        self.label = label
        self.value = value
    }
}
