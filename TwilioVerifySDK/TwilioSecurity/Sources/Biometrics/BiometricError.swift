//
//  BiometricError.swift
//  TwilioVerifySDK
//
//  Created by Alejandro Orozco Builes on 17/09/21.
//  Copyright © 2021 Twilio. All rights reserved.
//

import Foundation
import LocalAuthentication

/// Biometric Errors derived by LAError's LocalAuthentication. For more information, see https://developer.apple.com/documentation/localauthentication/laerror
/// Biometric Errors derived by OSStatus. For more information, see https://developer.apple.com/documentation/security/1542001-security_framework_result_codes
public enum BiometricError: Error, LocalizedError {
    // MARK: - Custom Errors

    case didChangeBiometrics

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

    // MARK: - Biometric OSStatus error cases

    case secAuthFailed
    case secNotAvailable
    case secReadOnly
    case secInvalidKeychain
    case secItemNotFound

    public var errorDescription: String? {
        return "Biometric error: \(String(describing: self))"
    }

    // MARK: - Resolution

    public static func given(_ error: NSError?) -> Self? {
      guard let error = error else {
        return nil
      }

      switch error.domain {
        case kLAErrorDomain:
          return laError(error.code)
        case NSOSStatusErrorDomain:
          return osStatusError(error.code)
        default: return nil
      }
    }

    public static func given(_ error: KeychainError) -> Self? {
      switch error {
        case .invalidStatusCode(let code) where error.domain == kLAErrorDomain,
             .invalidProtection(let code) where error.domain == kLAErrorDomain:
          return laError(code)
        case .invalidStatusCode(let code) where error.domain == NSOSStatusErrorDomain,
             .invalidProtection(let code) where error.domain == NSOSStatusErrorDomain:
          return osStatusError(code)
        default: return nil
      }
    }

    // MARK: - Private Methods

    // swiftlint:disable:next cyclomatic_complexity
    private static func laError(_ errorCode: Int) -> Self? {
        switch LAError.Code(rawValue: errorCode) {
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

    private static func osStatusError(_ errorCode: Int) -> Self? {
        switch errorCode {
            case Int(errSecAuthFailed): return .secAuthFailed
            case Int(errSecNotAvailable): return .secNotAvailable
            case Int(errSecReadOnly): return .secReadOnly
            case Int(errSecInvalidKeychain): return .secInvalidKeychain
            case Int(errSecItemNotFound): return .secItemNotFound
            default: return nil
        }
    }
}
