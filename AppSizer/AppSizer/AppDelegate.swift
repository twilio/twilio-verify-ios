//
//  AppDelegate.swift
//  AppSizer
//
//  Created by Santiago Avila on 6/8/20.
//  Copyright © 2020 Twilio. All rights reserved.
//

import UIKit
import TwilioVerify
import TwilioSecurity

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

  var window: UIWindow?

  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    print("TwilioSecurityVersion: \(KeyManager())")
    print("TwilioVerifyVersion: \(TwilioVerifyBuilder().build())")
    return true
  }
}

