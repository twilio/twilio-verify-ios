//
//  JwtSigner.swift
//  TwilioVerify
//
//  Created by Yeimi Moreno on 6/8/20.
//  Copyright © 2020 Twilio. All rights reserved.
//

import Foundation
import TwilioSecurity

protocol JwtSignerProtocol {
  func sign(message: String, withSignerTemplate signerTemplate: SignerTemplate) -> Data
}

class JwtSigner: JwtSignerProtocol {
  func sign(message: String, withSignerTemplate signerTemplate: SignerTemplate) -> Data {
    // TODO: Generate signature for jwt
    return message.data(using: .utf8)!
  }
}
