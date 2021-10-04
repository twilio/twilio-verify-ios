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
                return laError(error)
            case NSOSStatusErrorDomain:
                return osStatusError(error)
            default: return nil
        }
    }

    // MARK: - Private Methods

    // swiftlint:disable:next cyclomatic_complexity
    private static func laError(_ error: NSError) -> Self? {
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

    private static func osStatusError(_ error: NSError) -> Self? {
        switch error.code {
            case Int(errSecAuthFailed): return .secAuthFailed
            case Int(errSecNotAvailable): return .secNotAvailable
            case Int(errSecReadOnly): return .secReadOnly
            case Int(errSecInvalidKeychain): return .secInvalidKeychain
            default: return nil
        }
    }
}
