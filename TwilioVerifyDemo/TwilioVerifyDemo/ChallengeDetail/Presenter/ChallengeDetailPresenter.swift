//
//  ChallengeDetailPresenter.swift
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

import Foundation
import TwilioVerifySDK
import TwilioVerifyDemoCache

protocol ChallengeDetailPresentable {
  var challenge: AppChallenge! {get}
  func loadChallenge()
  func updateChallenge(withStatus status: ChallengeStatus)
}

class ChallengeDetailPresenter {
  
  private(set) var challenge: AppChallenge! {
    didSet {
      view?.updateView()
    }
  }

  private weak var view: ChallengeDetailView?
  private let twilioVerify: TwilioVerify
  private let challengeSid: String
  private let factorSid: String
  
  init?(withView view: ChallengeDetailView, challengeSid: String = String(), factorSid: String = String()) {
    self.view = view
    guard let twilioVerify = DIContainer.shared.resolve(type: TwilioVerifyAdapter.self) else {
      return nil
    }
    self.twilioVerify = twilioVerify
    self.challengeSid = challengeSid
    self.factorSid = factorSid
  }
}

extension ChallengeDetailPresenter: ChallengeDetailPresentable {
  func loadChallenge() {
    if let storedChallenge = ChallengesCache.storedChallenges.first(where: {$0.sid == challengeSid }) {
      challenge = storedChallenge
      ChallengesCache.deleteStoredChallenge(storedChallenge)
    } else {
      fetchChallengeDetails()
    }
  }

  func fetchChallengeDetails() {
    twilioVerify.getChallenge(challengeSid: challengeSid, factorSid: factorSid, success: { [weak self] challenge in
      guard let strongSelf = self else { return }
      strongSelf.challenge = challenge.toAppChallenge()
    }) { [weak self] error in
      guard let strongSelf = self else { return }
      strongSelf.view?.showAlert(withMessage: error.errorMessage)
    }
  }
  
  func updateChallenge(withStatus status: ChallengeStatus) {
    let payload = UpdatePushChallengePayload(
      factorSid: factorSid,
      challengeSid: challengeSid,
      status: status
      )
    twilioVerify.updateChallenge(withPayload: payload, success: { [weak self] in
      guard let strongSelf = self else { return }
      strongSelf.fetchChallengeDetails()
    }) { [weak self] error in
      guard let strongSelf = self else { return }
      strongSelf.view?.showAlert(withMessage: error.errorMessage)
    }
  }
}
