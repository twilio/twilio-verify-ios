import LocalAuthentication
import Foundation
@testable import TwilioVerifySDK

class StubLAContext: LAContext {
  override func evaluatePolicy(
    _ policy: LAPolicy,
    localizedReason: String,
    reply: @escaping (Bool, Error?) -> Void
  ) {}
  
  override func canEvaluatePolicy(
    _ policy: LAPolicy,
    error: NSErrorPointer
  ) -> Bool { true }
  
  static func getAccessControl(
    keychain: KeychainProtocol
  ) throws -> SecAccessControl {
    
    return try keychain.accessControl(
      withProtection: kSecAttrAccessibleAlways,
      flags: .touchIDCurrentSet
    )
  }
}
