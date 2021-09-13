import UserNotifications
import TwilioVerifySDK

class NotificationService: UNNotificationServiceExtension {
  
  private var twilioVerify: TwilioVerify?
  private let errorMessage = "Unable to silently approve the challenge, tap to manually approve it."
  
  var contentHandler: ((UNNotificationContent) -> Void)?
  var bestAttemptContent: UNMutableNotificationContent?
  
  override func didReceive(
    _ request: UNNotificationRequest,
    withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void
  ) {
    self.twilioVerify = try? TwilioVerifyBuilder().build()
    self.contentHandler = contentHandler
    
    bestAttemptContent = (request.content.mutableCopy() as? UNMutableNotificationContent)
    
    guard let bestAttemptContent = bestAttemptContent else {
      return
    }
    
    guard let challengeSid = request.content.userInfo["challenge_sid"] as? String,
          let factorSid = request.content.userInfo["factor_sid"] as? String,
          let type = request.content.userInfo["type"] as? String,
          type == "verify_push_challenge" else {
      contentHandler(bestAttemptContent)
      return
    }
    
    #warning("TODO: Validate if the current factor has the `silent approve` option enabled")
    
    updateChallenge(
      with: .approved,
      notificationPayload: request.content.userInfo as? [String : Any] ?? [:],
      factorSid: factorSid,
      challengeSid: challengeSid
    ) { [weak self] success in
      if success {
        bestAttemptContent.body = "Challenge silently approved"
      } else {
        bestAttemptContent.body = self?.errorMessage ?? bestAttemptContent.body
      }
      
      contentHandler(bestAttemptContent)
    }
  }
  
  override func serviceExtensionTimeWillExpire() {
    // Called just before the extension will be terminated by the system.
    // Use this as an opportunity to deliver your "best attempt" at modified content, otherwise the original push payload will be used.
    if let contentHandler = contentHandler,
       let bestAttemptContent =  bestAttemptContent {
      
      bestAttemptContent.body = errorMessage
      
      contentHandler(bestAttemptContent)
    }
  }
  
  private func updateChallenge(with status: ChallengeStatus,
                               notificationPayload: [String: Any],
                               factorSid: String,
                               challengeSid: String,
                               onCompletion: @escaping (_ success: Bool) -> Void) {
    
    let payload = UpdatePushChallengePayload(
      factorSid: factorSid,
      challengeSid: challengeSid,
      status: status
    )
        
    twilioVerify?.updateChallenge(withPayload: payload, success: {
      print("Challenge approved!")
      onCompletion(true)
    }) { error in
      onCompletion(false)
      print("Unable to silenty approve this challenge, details: \(error)")
    }
  }
}
