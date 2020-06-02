//
//  FactorType.swift
//  TwilioVerify
//
//  Created by Sergio Fierro on 6/2/20.
//  Copyright © 2020 Twilio. All rights reserved.
//

import Foundation

public enum FactorType {
  case push
}

extension FactorType {
  var value: String {
    switch self {
      case .push:
        return "push"
    }
  }
}
