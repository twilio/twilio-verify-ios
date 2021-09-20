//
//  BiometricError.swift
//  TwilioVerifySDK
//
//  Created by Alejandro Orozco Builes on 17/09/21.
//  Copyright © 2021 Twilio. All rights reserved.
//

import Foundation
import LocalAuthentication

public enum BiometricError: Error, LocalizedError {

    // MARK: - Biometric LAError cases

    case appCancel
    case authenticationFailed
    case invalidContext
    case notInteractive
    case passcodeNotSet
    case systemCancel
    case userCancel
    case userFallback
    case biometryLockout
    case biometryNotAvailable
    case biometryNotEnrolled

    public var errorDescription: String? {
        return "Biometric error: LAError \(String(describing: self))"
    }

    // MARK: - Resolution

    public static func given(_ error: NSError?) -> Self? {
      guard let error = error else {
        return nil
      }

      switch LAError.Code(rawValue: error.code) {
        case .appCancel: return .appCancel
        case .authenticationFailed: return .authenticationFailed
        case .invalidContext: return .invalidContext
        case .notInteractive: return .notInteractive
        case .passcodeNotSet: return .passcodeNotSet
        case .systemCancel: return .systemCancel
        case .userCancel: return .userCancel
        case .userFallback: return .userFallback
        case .biometryLockout: return .biometryLockout
        case .biometryNotAvailable: return .biometryNotAvailable
        case .biometryNotEnrolled: return .biometryNotEnrolled
        default: return nil
        }
    }
}
