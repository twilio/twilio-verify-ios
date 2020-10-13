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
  
  init(challengeProvider: ChallengeProvider, jwtGenerator: JwtGeneratorProtocol = JwtGenerator()) {
    self.challengeProvider = challengeProvider
    self.jwtGenerator = jwtGenerator
  }
}

extension PushChallengeProcessor: PushChallengeProcessorProtocol {
  func getChallenge(withSid sid: String, withFactor factor: PushFactor, success: @escaping ChallengeSuccessBlock, failure: @escaping TwilioVerifyErrorBlock) {
    challengeProvider.get(withSid: sid, withFactor: factor, success: success, failure: { error in
      failure(TwilioVerifyError.inputError(error: error as NSError))
    })
  }
  
  func updateChallenge(withSid sid: String, withFactor factor: PushFactor, status: ChallengeStatus, success: @escaping EmptySuccessBlock, failure: @escaping TwilioVerifyErrorBlock) {
    getChallenge(withSid: sid, withFactor: factor, success: { [weak self] challenge in
      guard let strongSelf = self else { return }
      guard let factorChallenge = challenge as? FactorChallenge else {
        failure(TwilioVerifyError.inputError(error: InputError.invalidInput as NSError))
        return
      }
      guard factorChallenge.factor is PushFactor, factorChallenge.factor?.sid == factor.sid else {
        failure(TwilioVerifyError.inputError(error: InputError.invalidInput as NSError))
        return
      }
      guard let alias = factor.keyPairAlias else {
        failure(TwilioVerifyError.storageError(error: StorageError.error("Alias not found") as NSError))
        return
      }
      guard let signatureFields = factorChallenge.signatureFields, !signatureFields.isEmpty else {
        failure(TwilioVerifyError.inputError(error: InputError.invalidInput as NSError))
        return
      }
      guard let response = factorChallenge.response, !response.isEmpty else {
        failure(TwilioVerifyError.inputError(error: InputError.invalidInput as NSError))
        return
      }
      var signerTemplate: SignerTemplate
      do {
        signerTemplate = try ECP256SignerTemplate(withAlias: alias, shouldExist: true)
      } catch {
        failure(TwilioVerifyError.keyStorageError(error: error as NSError))
        return
      }
      do {
        let authPayload = try strongSelf.generateSignature(withSignatureFields: signatureFields, withResponse: response, status: status, signerTemplate: signerTemplate)
        strongSelf.challengeProvider.update(challenge, payload: authPayload, success: { updatedChallenge in
          if updatedChallenge.status == status {
            success()
          } else {
            failure(TwilioVerifyError.inputError(error: InputError.invalidInput as NSError))
          }
        }, failure: { error in
          failure(TwilioVerifyError.inputError(error: error as NSError))
        })
      } catch {
        failure(TwilioVerifyError.inputError(error: error as NSError))
      }
    }, failure: failure)
  }
}

private extension PushChallengeProcessor {
  func generateSignature(withSignatureFields signatureFields: [String], withResponse response: [String: Any], status: ChallengeStatus, signerTemplate: SignerTemplate) throws -> String {
    var payload = try signatureFields.reduce(into: [String: Any]()) { result, key in
      guard let value = response[key] else {
        throw InputError.invalidInput
      }
      result[key] = value
    }
    payload[Constants.status] = status.rawValue
    return try jwtGenerator.generateJWT(forHeader: [:], forPayload: payload, withSignerTemplate: signerTemplate)
  }
}

extension PushChallengeProcessor {
  struct Constants {
    static let status = "status"
  }
}
