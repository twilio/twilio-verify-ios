//
//  KeyError.swift
//  TwilioSecurity
//
//  Created by Santiago Avila on 5/18/20.
//  Copyright © 2020 Twilio. All rights reserved.
//

import Foundation

enum KeyError: LocalizedError {
  case accessControlCreation
  
  var localizedDescription: String {
    switch self {
      case .accessControlCreation:
        return "Error creating access control"
    }
  }
}
