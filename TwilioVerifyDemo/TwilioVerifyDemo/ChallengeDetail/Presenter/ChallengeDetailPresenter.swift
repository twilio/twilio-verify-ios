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
    twilioVerify.getChallenge(challengeSid: challengeSid, factorSid: factorSid, success: { challenge in
      self.challenge = challenge
    }) { error in
      print(error)
    }
  }

}
