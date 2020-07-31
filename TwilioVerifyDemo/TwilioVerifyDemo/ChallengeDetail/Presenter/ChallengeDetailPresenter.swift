//
//  ChallengeDetailPresenter.swift
//  TwilioVerifyDemo
//
//  Created by Santiago Avila on 7/8/20.
//  Copyright © 2020 Twilio. All rights reserved.
//

import Foundation
import TwilioVerify

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
  
  init(withView view: ChallengeDetailView,
       twilioVerify: TwilioVerify = TwilioVerifyAdapter(),
       challengeSid: String = String(),
       factorSid: String = String()) {
    self.view = view
    self.twilioVerify = twilioVerify
    self.challengeSid = challengeSid
    self.factorSid = factorSid
    fetchChallengeDetails()
  }
}

extension ChallengeDetailPresenter: ChallengeDetailPresentable {
  func fetchChallengeDetails() {
    twilioVerify.getChallenge(challengeSid: challengeSid, factorSid: factorSid, success: { [weak self] challenge in
      guard let strongSelf = self else { return }
      strongSelf.challenge = challenge
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
