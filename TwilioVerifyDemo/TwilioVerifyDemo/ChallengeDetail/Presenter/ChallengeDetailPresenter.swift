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

protocol ChallengeDetailPresentable {
  var challenge: Challenge! {get}
  func fetchChallengeDetails()
  func updateChallenge(withStatus status: ChallengeStatus)
}

class ChallengeDetailPresenter {
  
  var challenge: Challenge! {
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
    fetchChallengeDetails()
  }
  
  private func getErrorMessage(
    from error: TwilioVerifyError
  ) -> String {
    if case .inputError(let detail) = error,
        let inputError = detail as? InputError,
        let errorDescription = inputError.errorDescription {
      return "\(error.localizedDescription). \(errorDescription)"
    }
    return error.localizedDescription
  }
}

extension ChallengeDetailPresenter: ChallengeDetailPresentable {
  func fetchChallengeDetails() {
    twilioVerify.getChallenge(challengeSid: challengeSid, factorSid: factorSid, success: { [weak self] challenge in
      guard let strongSelf = self else { return }
      strongSelf.challenge = challenge
    }) { [weak self] error in
      guard let self = self else { return }
      self.view?.showAlert(withMessage: self.getErrorMessage(from: error))
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
      guard let self = self else { return }
      self.view?.showAlert(withMessage: self.getErrorMessage(from: error))
    }
  }
}
