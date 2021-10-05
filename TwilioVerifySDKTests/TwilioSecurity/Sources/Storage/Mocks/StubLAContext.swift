import LocalAuthentication
import Foundation
@testable import TwilioVerifySDK

class StubLAContext: LAContext {
  override func evaluatePolicy(_ policy: LAPolicy, localizedReason: String, reply: @escaping (Bool, Error?) -> Void) {}
  override func canEvaluatePolicy(_ policy: LAPolicy, error: NSErrorPointer) -> Bool { return true }
  
  static func getAccessControl(keychain: KeychainProtocol) -> SecAccessControl {
    if #available(iOS 11.3, *) {
      return try! keychain.accessControl(
        withProtection: kSecAttrAccessibleWhenPasscodeSetThisDeviceOnly,
        flags: .biometryCurrentSet
      )
    }
    
    return try! keychain.accessControl(
      withProtection: kSecAttrAccessibleWhenPasscodeSetThisDeviceOnly,
      flags: .touchIDCurrentSet
    )
  }
}
