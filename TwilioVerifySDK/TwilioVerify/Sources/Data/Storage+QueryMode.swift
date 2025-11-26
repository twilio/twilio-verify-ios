//
//  Storage+QueryMode.swift
//  TwilioVerifySDK
//
//  Created by Alejandro Orozco Builes on 25/11/25.
//  Copyright © 2025 Twilio. All rights reserved.
//


public enum KeychainQueryMode {
  /// **Recommended for new integrations.**
  /// Filters Keychain items by the specific Service name (`TwilioVerify`).
  /// This isolates the SDK data and prevents collisions with keychain items or other libraries.
  case strict

  /// **Use only for backward compatibility.**
  /// Queries the Keychain without a Service filter.
  /// Use this if you have users on older versions of the SDK and need to migrate their data.
  /// Warning: May cause collisions if other keychain items exist with similar attributes.
  case legacy
}
