//
//  AppDelegate.swift
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

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

  var window: UIWindow?

  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    if #available(iOS 13.0, *) {
      let appearance = UINavigationBarAppearance()
      appearance.backgroundColor = .curiousBlue
      appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
      appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]

      UINavigationBar.appearance().tintColor = .white
      UINavigationBar.appearance().standardAppearance = appearance
      UINavigationBar.appearance().compactAppearance = appearance
      UINavigationBar.appearance().scrollEdgeAppearance = appearance
    } else {
      UINavigationBar.appearance().tintColor = .white
      UINavigationBar.appearance().barTintColor = .curiousBlue
      UINavigationBar.appearance().isTranslucent = false
    }
    
    UNUserNotificationCenter.current().delegate = self
    return true
  }
  
  func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
    let deviceTokenString = deviceToken.map { data in String(format: "%02.2hhx", data) }.joined()
    let tokenInServer = UserDefaults.standard.object(forKey: "PushToken") as? String ?? String()
    
    if tokenInServer != deviceTokenString {
      UserDefaults.standard.set(true, forKey: "ShouldUpdatePushToken")
      UserDefaults.standard.set(deviceTokenString, forKey: "PushToken")
    } else {
      UserDefaults.standard.set(false, forKey: "ShouldUpdatePushToken")
    }
  }
  
  func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
    print(error)
  }
}

extension AppDelegate: UNUserNotificationCenterDelegate {
  func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification,
                              withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
    completionHandler([.alert, .sound, .badge])
  }
  
  func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
    defer { completionHandler() }
    
    guard response.actionIdentifier == UNNotificationDefaultActionIdentifier,
          let payload = response.notification.request.content.userInfo["data"] as? [String: Any],
          let challengeSid = payload["challenge_sid"] as? String,
          let factorSid = payload["factor_sid"] as? String,
          let type = payload["type"] as? String, type == "verify_push_challenge" else {
      return
    }
    
    let storyboard = UIStoryboard(name: "Main", bundle: nil)
    guard let challengeNavigation = storyboard.instantiateViewController(withIdentifier: "ChallengeView") as? UINavigationController,
          let challengeView = challengeNavigation.viewControllers[0] as? ChallengeDetailViewController & ChallengeDetailView else {
      return
    }
    
    challengeView.presenter = ChallengeDetailPresenter(
      withView: challengeView,
      challengeSid: challengeSid,
      factorSid: factorSid
    )
    challengeView.shouldShowButtonToDismissView = true
    
    window?.rootViewController?.present(challengeNavigation, animated: true, completion: nil)
  }
}
