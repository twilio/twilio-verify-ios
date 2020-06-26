//
//  AppDelegate.swift
//  TwilioVerifyDemo
//
//  Created by Santiago  Avila on 5/15/20.
//  Copyright © 2020 Twilio. All rights reserved.
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
    return true
  }
  
  func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
    let deviceTokenString = deviceToken.map { data in String(format: "%02.2hhx", data) }.joined()
    UserDefaults.standard.set(deviceTokenString, forKey: "PushToken")
  }
}
