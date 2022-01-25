//
//  NotificationService.swift
//  TwilioVerifyDemo
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

import UserNotifications
import TwilioVerifySDK
import TwilioVerifyDemoCache

final class NotificationService: UNNotificationServiceExtension {

  // MARK: - Properties
  
  var contentHandler: ((UNNotificationContent) -> Void)?
  var bestAttemptContent: UNMutableNotificationContent?

  // MARK: - Override Methods
  
  override func didReceive(
    _ request: UNNotificationRequest,
    withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void
  ) {
    self.contentHandler = contentHandler
    bestAttemptContent = (request.content.mutableCopy() as? UNMutableNotificationContent)

    guard
      let bestAttemptContent = bestAttemptContent,
      let challengeSid = bestAttemptContent.userInfo["challenge_sid"] as? String,
      let factorSid = bestAttemptContent.userInfo["factor_sid"] as? String,
      let twilioVerify = try? TwilioVerifyBuilder().build()
    else {
      return
    }

    let group = DispatchGroup()

    group.enter()
    storeChallengeDetails(
      twilioVerify: twilioVerify,
      challengeSid: challengeSid,
      factorSid: factorSid
    ) { didSucceed in
      if didSucceed {
        bestAttemptContent.subtitle = "Pending Challenge"
      }
      group.leave()
    }

    group.wait()
    contentHandler(bestAttemptContent)
  }
  
  override func serviceExtensionTimeWillExpire() {
    if let contentHandler = contentHandler, let bestAttemptContent = bestAttemptContent {
      contentHandler(bestAttemptContent)
    }
  }

  // MARK: - Private Methods

  func storeChallengeDetails(
    twilioVerify: TwilioVerify,
    challengeSid: String,
    factorSid: String,
    completionHandler: @escaping (Bool) -> Void
  ) {
    twilioVerify.getChallenge(
      challengeSid: challengeSid,
      factorSid: factorSid
    ) { challenge in
      ChallengesCache.save(challenge: challenge.toAppChallenge())
      NSLog("Challenge Stored Successfully")
      completionHandler(true)
    } failure: { error in
      NSLog("Challenge Error: %@", error.localizedDescription)
      completionHandler(false)
    }
  }
}
