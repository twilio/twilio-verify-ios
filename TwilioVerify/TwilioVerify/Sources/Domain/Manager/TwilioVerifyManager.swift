//
//  TwilioVerifyManager.swift
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

///Handles the available operations to proccess Factors and Challenges
public class TwilioVerifyManager {
  
  private let factorFacade: FactorFacadeProtocol
  private let challengeFacade: ChallengeFacadeProtocol
  
  init(factorFacade: FactorFacadeProtocol, challengeFacade: ChallengeFacadeProtocol) {
    self.factorFacade = factorFacade
    self.challengeFacade = challengeFacade
  }
}

extension TwilioVerifyManager: TwilioVerify {
  /**
  Creates a **Factor** from a **FactorPayload**
  - Parameters:
    - payload: Describes the information needed to create a factor
    - success: Closure to be called when the operation succeeds, returns the created Factor
    - failure: Closure to be called when the operation fails with the cause of failure
  */
  public func createFactor(withPayload payload: FactorPayload, success: @escaping FactorSuccessBlock, failure: @escaping TwilioVerifyErrorBlock) {
    factorFacade.createFactor(withPayload: payload, success: success, failure: failure)
  }
  
  /**
  Verifies a **Factor** from a **VerifyFactorPayload**
  - Parameters:
    - payload: Describes the information needed to verify a factor
    - success: Closure to be called when the operation succeeds, returns the verified Factor
    - failure: Closure to be called when the operation fails with the cause of failure
  */
  public func verifyFactor(withPayload payload: VerifyFactorPayload, success: @escaping FactorSuccessBlock, failure: @escaping TwilioVerifyErrorBlock) {
    factorFacade.verifyFactor(withPayload: payload, success: success, failure: failure)
  }
  
  /**
  Updates a **Factor** from a **UpdateFactorPayload**
  - Parameters:
    - payload: Describes the information needed to update a factor
    - success: Closure to be called when the operation succeeds, returns the updated Factor
    - failure: Closure to be called when the operation fails with the cause of failure
  */
  public func updateFactor(withPayload payload: UpdateFactorPayload, success: @escaping FactorSuccessBlock, failure: @escaping TwilioVerifyErrorBlock) {
    factorFacade.updateFactor(withPayload: payload, success: success, failure: failure)
  }
  
  /**
  Gets all **Factors** created by the app
  - Parameters:
    - success: Closure to be called when the operation succeeds, returns an array of Factors
    - failure: Closure to be called when the operation fails with the cause of failure
  */
  public func getAllFactors(success: @escaping FactorListSuccessBlock, failure: @escaping TwilioVerifyErrorBlock) {
    factorFacade.getAll(success: success, failure: failure)
  }
  
  /**
  Deletes a **Factor** with the given **Sid**
  - Parameters:
    - sid: Sid of the **Factor** to be deleted
    - success: Closure to be called when the operation succeeds
    - failure: Closure to be called when the operation fails with the cause of failure
  */
  public func deleteFactor(withSid sid: String, success: @escaping EmptySuccessBlock, failure: @escaping TwilioVerifyErrorBlock) {
    factorFacade.delete(withSid: sid, success: success, failure: failure)
  }
  
  /**
  Gets a **Challenge** with the given challenge sid and factor Sid
  - Parameters:
    - challengeSid: Sid of the Challenge requested
    - factorSid: Sid of the Factor to which the Challenge corresponds
    - success: Closure to be called when the operation succeeds, returns the requested Challenge
    - failure: Closure to be called when the operation fails with the cause of failure
  */
  public func getChallenge(challengeSid: String, factorSid: String, success: @escaping ChallengeSuccessBlock, failure: @escaping TwilioVerifyErrorBlock) {
    challengeFacade.get(withSid: challengeSid, withFactorSid: factorSid, success: success, failure: failure)
  }
  
  /**
  Updates a **Challenge** from a **UpdateChallengePayload**
  - Parameters:
     - payload: Describes the information needed to update a challenge
     - success: Closure to be called when the operation succeeds
     - failure: Closure to be called when the operation fails with the cause of failure
  */
  public func updateChallenge(withPayload payload: UpdateChallengePayload, success: @escaping EmptySuccessBlock, failure: @escaping TwilioVerifyErrorBlock) {
    challengeFacade.update(withPayload: payload, success: success, failure: failure)
  }
  
  /**
   Gets all Challenges associated to a **Factor** with the given **ChallengeListPayload**
   - Parameters:
      - payload: Describes the information needed to fetch all the **Challenges**
      - success: Closure to be called when the operation succeeds, returns a ChallengeList which contains the Challenges and the metadata associated to the request
      - failure: Closure to be called when the operation fails with the cause of failure
   */
  public func getAllChallenges(withPayload payload: ChallengeListPayload, success: @escaping (ChallengeList) -> (), failure: @escaping TwilioVerifyErrorBlock) {
    challengeFacade.getAll(withPayload: payload, success: success, failure: failure)
  }
  
  /**
  Clears local storage, it will delete factors and key pairs in this device.
  - throws: An error, if there is an error clearing the local storage.
  ## Important Note ##
  Calling this method will not delete factors in **Verify Push API**, so you need to delete
  them from your backend to prevent invalid/deleted factors when getting factors for an identity.
  */
  public func clearLocalStorage() throws {
    try factorFacade.clearLocalStorage()
  }
}
