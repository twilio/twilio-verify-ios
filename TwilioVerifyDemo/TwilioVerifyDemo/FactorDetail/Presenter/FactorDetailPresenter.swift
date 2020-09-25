//
//  FactorDetailPresenter.swift
//  TwilioVerifyDemo
//
//  Copyright © 2020 Twilio. All rights reserved.
//  This file is licensed under the Apache License 2.0.
//  License text available at https://github.com/twilio/twilio-verify-ios/blob/main/LICENSE
//

import Foundation
import TwilioVerify

protocol FactorDetailPresentable {
  var factor: Factor {get}
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
    do {
      self.view = view
      self.twilioVerify = try TwilioVerifyAdapter()
      self.factor = factor
      self.challenges = []
      fetchChallenges()
    } catch {
      print("Unexpected error: \(error).")
      return nil
    }
  }
}

extension FactorDetailPresenter: FactorDetailPresentable {
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
    let payload = ChallengeListPayload(factorSid: factor.sid, pageSize: 20)
    twilioVerify.getAllChallenges(withPayload: payload, success: { [weak self] list in
      guard let strongSelf = self else { return }
      strongSelf.challenges = list.challenges
    }) { [weak self] error in
      guard let strongSelf = self else { return }
      strongSelf.view?.showAlert(withMessage: error.errorMessage)
    }
  }
}
