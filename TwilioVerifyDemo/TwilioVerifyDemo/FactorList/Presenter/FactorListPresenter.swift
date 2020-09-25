//
//  FactorListPresenter.swift
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
import TwilioVerify
import UserNotifications

protocol FactorListPresentable {
  func getFactors()
  func numberOfItems() -> Int
  func factor(at index: Int) -> Factor
  func delete(at index: Int)
  func registerForPushNotifications()
}

class FactorListPresenter {
  
  private weak var view: FactorListView?
  private let twilioVerify: TwilioVerify
  private var factors: [Factor]
  
  init?(withView view: FactorListView) {
    do {
      self.view = view
      self.twilioVerify = try TwilioVerifyAdapter()
      self.factors = [Factor]()
    } catch {
      print("Unexpected error: \(error).")
      return nil
    }
  }
}

extension FactorListPresenter: FactorListPresentable {
  func registerForPushNotifications() {
    UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
      guard granted else {
        return
      }
      UNUserNotificationCenter.current().getNotificationSettings { settings in
        guard settings.authorizationStatus == .authorized else { return }
        DispatchQueue.main.async {
          UIApplication.shared.registerForRemoteNotifications()
        }
      }
    }
  }
  
  func getFactors() {
    twilioVerify.getAllFactors(success: { [weak self] factorList in
      guard let strongSelf = self else { return }
      strongSelf.factors = factorList
      strongSelf.updatePushTokenIfNeeded()
      strongSelf.view?.reloadData()
    }) { [weak self] error in
      guard let strongSelf = self else { return }
      strongSelf.view?.showAlert(withMessage: error.errorMessage)
    }
  }
  
  func numberOfItems() -> Int {
    factors.count
  }
  
  func factor(at index: Int) -> Factor {
    factors[index]
  }
  
  func delete(at index: Int) {
    let factor = factors.remove(at: index)
    view?.reloadData()
    twilioVerify.deleteFactor(withSid: factor.sid, success: {
    }) { [weak self] error in
      guard let strongSelf = self else { return }
      strongSelf.factors.insert(factor, at: index)
      strongSelf.view?.reloadData()
      strongSelf.view?.showAlert(withMessage: error.errorMessage)
    }
  }
}

private extension FactorListPresenter {
  func updatePushTokenIfNeeded() {
    let shouldUpdatePushToken = UserDefaults.standard.bool(forKey: "ShouldUpdatePushToken")
    let pushToken = UserDefaults.standard.object(forKey: "PushToken") as? String ?? String()
    if shouldUpdatePushToken {
      UserDefaults.standard.set(false, forKey: "ShouldUpdatePushToken")
      updateFactors(withPushToken: pushToken)
    }
  }
  
  func updateFactors(withPushToken pushToken: String) {
    let queue = DispatchQueue(label: "com.twilio.verify.updateFactors", qos: .utility)
    factors.forEach {
      let payload = UpdatePushFactorPayload(sid: $0.sid, pushToken: pushToken)
      queue.async { [weak self] in
        guard let strongSelf = self else { return }
        strongSelf.twilioVerify.updateFactor(withPayload: payload, success: { _ in
        }) { error in
          print(error.errorMessage)
        }
      }
    }
  }
}
