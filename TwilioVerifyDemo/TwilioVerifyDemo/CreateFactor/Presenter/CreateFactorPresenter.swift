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
  func create(withIdentity identity: String?, accessTokenURL: String?)
  func accessTokenURL() -> String?
}

class CreateFactorPresenter {
  
  private weak var view: CreateFactorView?
  private let twilioVerify: TwilioVerify
  private let accessTokensAPI: AccessTokensAPI
  
  init?(withView view: CreateFactorView,
       accessTokensAPI: AccessTokensAPI = AccessTokensAPIClient()) {
    do {
      self.view = view
      self.twilioVerify = try TwilioVerifyAdapter()
      self.accessTokensAPI = accessTokensAPI
    } catch {
      print("Unexpected error: \(error).")
      return nil
    }
  }
}

extension CreateFactorPresenter: CreateFactorPresentable {
  func create(withIdentity identity: String?, accessTokenURL: String?) {
    guard let identity = identity, !identity.isEmpty else {
      view?.showAlert(withMessage: "Invalid Identity")
      return
    }
    guard let url = accessTokenURL, !url.isEmpty else {
      view?.showAlert(withMessage: "Invalid URL")
      return
    }
    saveAccessTokenURL(url)
    accessTokensAPI.accessTokens(at: url, identity: identity, success: { [weak self] response in
      guard let strongSelf = self else { return }
      let factorName = "\(identity)'s Factor"
      strongSelf.createFactor(response, withFactorName: factorName, success: { factor in
        strongSelf.verify(factor, success: { factor in
          strongSelf.view?.stopLoader()
          strongSelf.view?.dismissView()
        }) { error in
          guard let strongSelf = self else { return }
          DispatchQueue.main.async {
            strongSelf.view?.showAlert(withMessage: error.errorMessage)
          }
        }
      }) { error in
        guard let strongSelf = self else { return }
        DispatchQueue.main.async {
          strongSelf.view?.showAlert(withMessage: error.errorMessage)
        }
      }
    }) {[weak self] error in
      guard let strongSelf = self else { return }
      DispatchQueue.main.async {
        strongSelf.view?.showAlert(withMessage: error.localizedDescription)
      }
    }
  }
  
  func accessTokenURL() -> String? {
    return UserDefaults.standard.value(forKey: Constants.accessTokenURLKey) as? String
  }
}

private extension CreateFactorPresenter {
  
  struct Constants {
    static let accessTokenURLKey = "accessTokenURL"
    static let pushTokenKey = "PushToken"
    static let dummyPushToken = "0000000000000000000000000000000000000000000000000000000000000000"
  }
  
  func saveAccessTokenURL(_ url: String) {
    UserDefaults.standard.set(url, forKey: Constants.accessTokenURLKey)
  }
  
  func pushToken() -> String {
    if TARGET_OS_SIMULATOR == 1 {
      return Constants.dummyPushToken
    }
    return UserDefaults.standard.value(forKey: Constants.pushTokenKey) as? String ?? String()
  }
  
  func createFactor(_ accessToken: AccessTokenResponse, withFactorName factorName: String, success: @escaping FactorSuccessBlock, failure: @escaping TwilioVerifyErrorBlock) {
    let payload = PushFactorPayload(
      friendlyName: factorName,
      serviceSid: accessToken.serviceSid,
      identity: accessToken.identity,
      pushToken: pushToken(),
      accessToken: accessToken.token
    )
    twilioVerify.createFactor(withPayload: payload, success: success, failure: failure)
  }
  
  func verify(_ factor: Factor, success: @escaping FactorSuccessBlock, failure: @escaping TwilioVerifyErrorBlock) {
    let payload = VerifyPushFactorPayload(sid: factor.sid)
    twilioVerify.verifyFactor(withPayload: payload, success: success, failure: failure)
  }
}

