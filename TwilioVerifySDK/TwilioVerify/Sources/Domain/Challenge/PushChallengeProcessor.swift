//
//  PushChallengeProcessor.swift
//  TwilioVerify
//
//  Copyright © 2020 Twilio.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

import Foundation

protocol PushChallengeProcessorProtocol {
  func getChallenge(withSid sid: String, withFactor factor: PushFactor, success: @escaping ChallengeSuccessBlock, failure: @escaping TwilioVerifyErrorBlock)
  func updateChallenge(withSid sid: String, withFactor factor: PushFactor, status: ChallengeStatus, success: @escaping EmptySuccessBlock, failure: @escaping TwilioVerifyErrorBlock)
}

class PushChallengeProcessor {
  
  private let challengeProvider: ChallengeProvider
  private let jwtGenerator: JwtGeneratorProtocol
  
  init(
    challengeProvider: ChallengeProvider,
    jwtGenerator: JwtGeneratorProtocol
  ) {
    self.challengeProvider = challengeProvider
    self.jwtGenerator = jwtGenerator
  }
}

extension PushChallengeProcessor: PushChallengeProcessorProtocol {
  func getChallenge(
    withSid sid: String,
    withFactor factor: PushFactor,
    success: @escaping ChallengeSuccessBlock,
    failure: @escaping TwilioVerifyErrorBlock
  ) {
    Logger.shared.log(withLevel: .info, message: "Getting challenge \(sid) with factor \(factor.sid)")
    challengeProvider.get(withSid: sid, withFactor: factor, success: success, failure: { error in
      failure(TwilioVerifyError.inputError(error: error))
    })
  }
  
  func updateChallenge(
    withSid sid: String,
    withFactor factor: PushFactor,
    status: ChallengeStatus,
    success: @escaping EmptySuccessBlock,
    failure: @escaping TwilioVerifyErrorBlock
  ) {
    Logger.shared.log(withLevel: .info, message: "Updating challenge \(sid) with factor \(factor.sid) to new status \(status)")
    getChallenge(withSid: sid, withFactor: factor, success: { [weak self] challenge in
      guard let strongSelf = self else { return }
      guard let factorChallenge = challenge as? FactorChallenge else {
        let error: InputError = .invalidChallenge
        Logger.shared.log(withLevel: .error, message: error.localizedDescription)
        failure(TwilioVerifyError.inputError(error: error))
        return
      }
      guard factorChallenge.factor is PushFactor, factorChallenge.factor?.sid == factor.sid else {
        let error: InputError = .wrongFactor
        Logger.shared.log(withLevel: .error, message: error.localizedDescription)
        failure(TwilioVerifyError.inputError(error: error))
        return
      }
      if factorChallenge.status == .expired {
        let error: InputError = .expiredChallenge
        Logger.shared.log(withLevel: .error, message: error.localizedDescription)
        failure(TwilioVerifyError.inputError(error: error))
        return
      }
      if factorChallenge.status != .pending {
        let error: InputError = .alreadyUpdatedChallenge
        Logger.shared.log(withLevel: .error, message: error.localizedDescription)
        failure(TwilioVerifyError.inputError(error: error))
        return
      }
      guard let alias = factor.keyPairAlias else {
        let error = StorageError.error("Alias not found")
        Logger.shared.log(withLevel: .error, message: error.localizedDescription)
        failure(TwilioVerifyError.storageError(error: error))
        return
      }
      guard let signatureFields = factorChallenge.signatureFields, !signatureFields.isEmpty else {
        let error: InputError = .signatureFields
        Logger.shared.log(withLevel: .error, message: error.localizedDescription)
        failure(TwilioVerifyError.inputError(error: error))
        return
      }
      guard let response = factorChallenge.response, !response.isEmpty else {
        let error: InputError = .signatureFields
        Logger.shared.log(withLevel: .error, message: error.localizedDescription)
        failure(TwilioVerifyError.inputError(error: error))
        return
      }
      var signerTemplate: SignerTemplate
      do {
        signerTemplate = try ECP256SignerTemplate(withAlias: alias, shouldExist: true)
      } catch {
        Logger.shared.log(withLevel: .error, message: error.localizedDescription)
        failure(TwilioVerifyError.keyStorageError(error: error))
        return
      }
      do {
        let authPayload = try strongSelf.generateSignature(withSignatureFields: signatureFields, withResponse: response, status: status, signerTemplate: signerTemplate)
        Logger.shared.log(withLevel: .debug, message: "Update challenge with auth payload \(authPayload)")
        strongSelf.challengeProvider.update(challenge, payload: authPayload, success: { updatedChallenge in
          if updatedChallenge.status == status {
            success()
          } else {
            let error: InputError = .notUpdatedChallenge
            Logger.shared.log(withLevel: .error, message: error.localizedDescription)
            failure(TwilioVerifyError.inputError(error: error))
          }
        }, failure: { error in
          failure(TwilioVerifyError.inputError(error: error))
        })
      } catch {
        Logger.shared.log(withLevel: .error, message: error.localizedDescription)
        failure(TwilioVerifyError.inputError(error: error))
      }
    }, failure: failure)
  }
}

private extension PushChallengeProcessor {
  func generateSignature(
    withSignatureFields signatureFields: [String],
    withResponse response: [String: Any],
    status: ChallengeStatus,
    signerTemplate: SignerTemplate
  ) throws -> String {
    var payload = try signatureFields.reduce(into: [String: Any]()) { result, key in
      guard let value = response[key] else {
        let error = InputError.invalidInput(field: "value in response")
        Logger.shared.log(withLevel: .error, message: error.localizedDescription)
        throw error
      }
      result[key] = value
    }
    payload[Constants.status] = status.rawValue
    Logger.shared.log(withLevel: .debug, message: "Update challenge with payload \(payload)")
    return try jwtGenerator.generateJWT(forHeader: [:], forPayload: payload, withSignerTemplate: signerTemplate)
  }
}

extension PushChallengeProcessor {
  struct Constants {
    static let status = "status"
  }
}
