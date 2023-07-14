//
//  CreateFactorPresenter.swift
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

import UIKit
import Foundation
import TwilioVerifySDK

protocol CreateFactorPresentable {
  func create(
    withIdentity identity: String?,
    accessTokenURL: String?,
    pushNotificationEnabled: Bool,
    allowIphoneMigration: Bool
  )
    
  func accessTokenURL() -> String?
}

class CreateFactorPresenter {
  
  private weak var view: CreateFactorView?
  private let twilioVerify: TwilioVerify
  private let accessTokensAPI: AccessTokensAPI
  
  init?(withView view: CreateFactorView, accessTokensAPI: AccessTokensAPI = AccessTokensAPIClient()) {
    self.view = view
    guard let twilioVerify = DIContainer.shared.resolve(type: TwilioVerifyAdapter.self) else {
      return nil
    }
    self.twilioVerify = twilioVerify
    self.accessTokensAPI = accessTokensAPI
  }
  
  /// This method is intended to demonstrate how to access to
  /// Verify API errors, such custom response codes and details.
  /// See https://www.twilio.com/docs/api/errors
  /// - Parameter error: Create Factor result error
  private func retrieveAPIError(
    with error: TwilioVerifyError
  ) -> String? {
    let apiError = error.originalError as? NetworkError
    
    if case let .failureStatusCode(response) = apiError {
      // Gets Verify API error response
      var errorResponse = response
      
      if let code = errorResponse.apiError?.code,
         let message = errorResponse.apiError?.message {
        return "Code: \(code) - \(message)"
      }
    }
    
    return nil
  }
}

extension CreateFactorPresenter: CreateFactorPresentable {
  func create(
    withIdentity identity: String?,
    accessTokenURL: String?,
    pushNotificationEnabled: Bool,
    allowIphoneMigration: Bool
  ) {
      
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
      
      let devicePushToken = pushNotificationEnabled ? strongSelf.pushToken : nil
      let factorName = "\(identity)'s Factor"
      let metadata = !pushNotificationEnabled ? ["os": "iOS"] : nil
      
      strongSelf.createFactor(
        response,
        withFactorName: factorName,
        devicePushToken: devicePushToken,
        metadata: metadata,
        allowIphoneMigration: allowIphoneMigration,
        success: { factor in
            
        strongSelf.verify(factor, allowIphoneMigration: allowIphoneMigration, success: { _ in
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
        
        let errorMessage = strongSelf.retrieveAPIError(
          with: error
        ) ?? error.errorMessage
                
        DispatchQueue.main.async {
          strongSelf.view?.showAlert(withMessage: errorMessage)
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
  }
  
  func saveAccessTokenURL(_ url: String) {
    UserDefaults.standard.set(url, forKey: Constants.accessTokenURLKey)
  }
  
  var pushToken: String? {
    if TARGET_OS_SIMULATOR == 1 { return nil }
    return UserDefaults.standard.value(forKey: Constants.pushTokenKey) as? String
  }
  
  func createFactor(
    _ accessToken: AccessTokenResponse,
    withFactorName factorName: String,
    devicePushToken: String?,
    metadata: [String: String]?,
    allowIphoneMigration: Bool,
    success: @escaping FactorSuccessBlock,
    failure: @escaping TwilioVerifyErrorBlock
  ) {
    let payload = PushFactorPayload(
      friendlyName: factorName,
      serviceSid: accessToken.serviceSid,
      identity: accessToken.identity,
      allowIphoneMigration: allowIphoneMigration,
      pushToken: devicePushToken,
      accessToken: accessToken.token,
      metadata: metadata
    )
    
    twilioVerify.createFactor(withPayload: payload, success: success, failure: failure)
  }
  
  func verify(
    _ factor: Factor,
    allowIphoneMigration: Bool,
    success: @escaping FactorSuccessBlock,
    failure: @escaping TwilioVerifyErrorBlock
  ) {
    let payload = VerifyPushFactorPayload(sid: factor.sid, allowIphoneMigration: allowIphoneMigration)
    twilioVerify.verifyFactor(withPayload: payload, success: success, failure: failure)
  }
}
