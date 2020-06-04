//
//  Authentication.swift
//  TwilioVerify
//
//  Created by Sergio Fierro on 6/4/20.
//  Copyright © 2020 Twilio. All rights reserved.
//

import Foundation

protocol Authentication {
  func generateJWT(factor: Factor) -> String
}

struct AuthenticationProvider: Authentication {
  func generateJWT(factor: Factor) -> String {
   //TODO: Authentication
    return "jwt"
  }
}
