//
//  FactorDetailPresenter.swift
//  TwilioVerifyDemo
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
import TwilioVerifySDK

protocol FactorDetailPresentable {
  var factor: Factor { get }
  var isSilentyApproved: Bool { get }
  
  func updateSilentlyApproveStatus()
  func didAppear()
  func numberOfItems() -> Int
  func challenge(at index: Int) -> Challenge
}

class FactorDetailPresenter {
  
  let factor: Factor
  private weak var view: FactorDetailView?
  private let twilioVerify: TwilioVerify
  private var challenges: [Challenge] {
    didSet {
      view?.updateChallengesList()
    }
  }
  
  init?(withView view: FactorDetailView?, factor: Factor) {
    self.view = view
    guard let twilioVerify = DIContainer.shared.resolve(type: TwilioVerifyAdapter.self) else {
      return nil
    }
    
    self.twilioVerify = twilioVerify
    self.factor = factor
    self.challenges = []
    fetchChallenges()
  }
}

extension FactorDetailPresenter: FactorDetailPresentable {
  var isSilentyApproved: Bool {
    AppModel.factorsSilentyApproved[factor.sid] == true
  }
  
  func updateSilentlyApproveStatus() {
    if !AppModel.factorsSilentyApproved.keys.contains(factor.sid) {
      AppModel.factorsSilentyApproved[factor.sid] = false
    }
    
    AppModel.factorsSilentyApproved[factor.sid]?.toggle()
  }
  
  func didAppear() {
    view?.updateFactorView()
  }
  
  func numberOfItems() -> Int {
    challenges.count
  }
  
  func challenge(at index: Int) -> Challenge {
    challenges[index]
  }
}

private extension FactorDetailPresenter {
  func fetchChallenges() {
    let payload = ChallengeListPayload(factorSid: factor.sid, pageSize: 20, order: .desc)
    twilioVerify.getAllChallenges(withPayload: payload, success: { [weak self] list in
      guard let strongSelf = self else { return }
      strongSelf.challenges = list.challenges
    }) { [weak self] error in
      guard let strongSelf = self else { return }
      strongSelf.view?.showAlert(withMessage: error.errorMessage)
    }
  }
}
