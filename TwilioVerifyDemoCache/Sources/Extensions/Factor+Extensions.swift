//
//  Factor+Extensions.swift
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

import TwilioVerifySDK

public extension Challenge {
    func toAppChallenge() -> AppChallenge {
        AppChallenge(
            sid: sid,
            challengeDetails: AppChallengeDetails(
                message: challengeDetails.message,
                fields: challengeDetails.fields.map {
                    AppChallengeDetailField(
                        label: $0.label,
                        value: $0.value
                    )
                }
            ),
            hiddenDetails: hiddenDetails,
            factorSid: factorSid,
            status: AppChallengeStatus(
                rawValue: status.rawValue
            ) ?? .undefined,
            updatedAt: updatedAt,
            expirationDate: expirationDate
        )
    }
}
