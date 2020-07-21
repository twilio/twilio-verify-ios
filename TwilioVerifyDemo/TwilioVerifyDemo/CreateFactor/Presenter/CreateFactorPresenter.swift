//
//  CreateFactorPresenter.swift
//  TwilioVerifyDemo
//
//  Created by Santiago Avila on 6/25/20.
//  Copyright © 2020 Twilio. All rights reserved.
//

import UIKit
import Foundation
import TwilioVerify

protocol CreateFactorPresentable {
  func create(withIdentity identity: String?, enrollmentURL: String?)
  func enrollmentURL() -> String?
}

class CreateFactorPresenter {
  
  private weak var view: CreateFactorView?
  private let twilioVerify: TwilioVerify
  private let enrollment: Enrollment
  
  init(withView view: CreateFactorView,
       twilioVerify: TwilioVerify = TwilioVerifyAdapter(),
       enrollment: Enrollment = EnrollmentAPI()) {
    self.view = view
    self.twilioVerify = twilioVerify
    self.enrollment = enrollment
  }
}

extension CreateFactorPresenter: CreateFactorPresentable {
  func create(withIdentity identity: String?, enrollmentURL: String?) {
    guard let identity = identity, !identity.isEmpty else {
      view?.showAlert(withMessage: "Invalid Entity")
      return
    }
    guard let url = enrollmentURL, !url.isEmpty else {
      view?.showAlert(withMessage: "Invalid URL")
      return
    }
    saveEnrollmentURL(url)
    enrollment.enroll(at: url, identity: identity, success: { [weak self] response in
      guard let strongSelf = self else { return }
      strongSelf.createFactor(response, success: { factor in
        strongSelf.verify(factor, success: { factor in
          strongSelf.view?.stopLoader()
          strongSelf.view?.dismiss()
        }) { error in
          guard let strongSelf = self else { return }
          DispatchQueue.main.async {
            strongSelf.view?.showAlert(withMessage: error.originalError.localizedDescription)
          }
        }
      }) { error in
        guard let strongSelf = self else { return }
        DispatchQueue.main.async {
          strongSelf.view?.showAlert(withMessage: error.originalError.localizedDescription)
        }
      }
    }) {[weak self] error in
      guard let strongSelf = self else { return }
      DispatchQueue.main.async {
        strongSelf.view?.showAlert(withMessage: error.localizedDescription)
      }
    }
  }
  
  func enrollmentURL() -> String? {
    return UserDefaults.standard.value(forKey: Constants.enrollmentURLKey) as? String
  }
}

private extension CreateFactorPresenter {
  
  struct Constants {
    static let enrollmentURLKey = "enrollmentURL"
    static let pushTokenKey = "PushToken"
    static let dummyPushToken = "0000000000000000000000000000000000000000000000000000000000000000"
  }
  
  func saveEnrollmentURL(_ url: String) {
    UserDefaults.standard.set(url, forKey: Constants.enrollmentURLKey)
  }
  
  func pushToken() -> String {
    if TARGET_OS_SIMULATOR == 1 {
      return Constants.dummyPushToken
    }
    return UserDefaults.standard.value(forKey: Constants.pushTokenKey) as? String ?? String()
  }
  
  func createFactor(_ enrollment: EnrollmentResponse, success: @escaping FactorSuccessBlock, failure: @escaping TwilioVerifyErrorBlock) {
    let payload = PushFactorPayload(
      friendlyName: "\(enrollment.identity)'s Factor",
      serviceSid: enrollment.serviceSid,
      identity: enrollment.identity,
      pushToken: pushToken(),
      enrollmentJwe: enrollment.token
    )
    twilioVerify.createFactor(withPayload: payload, success: success, failure: failure)
  }
  
  func verify(_ factor: Factor, success: @escaping FactorSuccessBlock, failure: @escaping TwilioVerifyErrorBlock) {
    let payload = VerifyPushFactorPayload(sid: factor.sid)
    twilioVerify.verifyFactor(withPayload: payload, success: success, failure: failure)
  }
}

