//
//  UpdateChallengeTests.swift
//  TwilioVerifyTests
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

import XCTest
@testable import TwilioVerify

// swiftlint:disable force_try function_body_length
class UpdateChallengeTests: BaseFactorTests {
  
  func testUpdateChallenge_withValidAPIResponse_shouldSucceed() {
    let expectation = self.expectation(description: "testUpdateChallenge_withValidData_shouldSucceed")
    guard let pathPendingChallengesString = Bundle(for: type(of: self)).path(forResource: Constants.pendingChallengesValidResponse, ofType: Constants.json),
      let jsonPendingChallengesString = try? String(contentsOfFile: pathPendingChallengesString, encoding: .utf8),
      let jsonPendingChallengesData = jsonPendingChallengesString.data(using: .utf8),
      let jsonPendingChallengesDictionary = try? JSONSerialization.jsonObject(with: jsonPendingChallengesData, options: []) as? [String: Any] else {
        fatalError("get_challenge_pending_valid_response.json not found")
    }
    guard let pathApprovedChallengesString = Bundle(for: type(of: self)).path(forResource: Constants.approvedChallengesValidResponse, ofType: Constants.json),
      let jsonApprovedChallengesString = try? String(contentsOfFile: pathApprovedChallengesString, encoding: .utf8),
      let jsonApprovedChallengesData = jsonApprovedChallengesString.data(using: .utf8) else {
        fatalError("get_challenge_approved_valid_response.json not found")
    }
    let headers = jsonPendingChallengesDictionary.keys.map { String($0) }.joined(separator: ChallengeMapper.Constants.signatureFieldsHeaderSeparator)
    let urlResponse = HTTPURLResponse(url: URL(string: Constants.url)!, statusCode: 200, httpVersion: "", headerFields: [ChallengeRepository.Constants.signatureFieldsHeader: headers])
    let urlSessionTasks = [URLSessionDataTaskMock(data: jsonPendingChallengesData, httpURLResponse: urlResponse, requestError: nil),
                           URLSessionDataTaskMock(data: "".data(using: .utf8), httpURLResponse: urlResponse, requestError: nil),
                           URLSessionDataTaskMock(data: jsonApprovedChallengesData, httpURLResponse: urlResponse, requestError: nil)]
    let urlSession = URLSessionMock(urlSessionDataTasks: urlSessionTasks)
    let networkProvider = NetworkAdapter(withSession: urlSession)
    let twilioVerify = try! TwilioVerifyBuilder()
                            .setURL(Constants.url)
                            .setNetworkProvider(networkProvider)
                            .setClearStorageOnReinstall(true)
                            .enableDefaultLoggingService(withLevel: .all)
                            .build()
    twilioVerify.updateChallenge(withPayload: Constants.generateUpdateChallengePayload(withFactorSid: factor!.sid), success: {
      expectation.fulfill()
    }) { _ in
      XCTFail()
      expectation.fulfill()
    }
    waitForExpectations(timeout: 3, handler: nil)
  }
  
  func testUpdateChallenge_withInvalidAPIResponseCode_shouldFail() {
    let expectation = self.expectation(description: "testUpdateChallenge_withInvalidAPIResponseCode_shouldFail")
    guard let pathPendingChallengesString = Bundle(for: type(of: self)).path(forResource: Constants.pendingChallengesValidResponse, ofType: Constants.json),
      let jsonPendingChallengesString = try? String(contentsOfFile: pathPendingChallengesString, encoding: .utf8),
      let jsonPendingChallengesData = jsonPendingChallengesString.data(using: .utf8),
      let jsonPendingChallengesDictionary = try? JSONSerialization.jsonObject(with: jsonPendingChallengesData, options: []) as? [String: Any] else {
        fatalError("get_challenge_pending_valid_response.json not found")
    }
    guard let pathApprovedChallengesString = Bundle(for: type(of: self)).path(forResource: Constants.approvedChallengesValidResponse, ofType: Constants.json),
      let jsonApprovedChallengesString = try? String(contentsOfFile: pathApprovedChallengesString, encoding: .utf8),
      let jsonApprovedChallengesData = jsonApprovedChallengesString.data(using: .utf8) else {
        fatalError("get_challenge_approved_valid_response.json not found")
    }
    let headers = jsonPendingChallengesDictionary.keys.map { String($0) }.joined(separator: ChallengeMapper.Constants.signatureFieldsHeaderSeparator)
    let urlSuccessResponse = HTTPURLResponse(
      url: URL(string: Constants.url)!,
      statusCode: 200,
      httpVersion: "",
      headerFields: [ChallengeRepository.Constants.signatureFieldsHeader: headers]
    )
    let urlErrorResponse = HTTPURLResponse(
      url: URL(string: Constants.url)!,
      statusCode: 400,
      httpVersion: "",
      headerFields: [ChallengeRepository.Constants.signatureFieldsHeader: headers]
    )
    let urlSessionTasks = [URLSessionDataTaskMock(data: jsonPendingChallengesData, httpURLResponse: urlSuccessResponse, requestError: nil),
                           URLSessionDataTaskMock(data: "".data(using: .utf8), httpURLResponse: urlSuccessResponse, requestError: nil),
                           URLSessionDataTaskMock(data: jsonApprovedChallengesData, httpURLResponse: urlErrorResponse, requestError: nil)]
    let urlSession = URLSessionMock(urlSessionDataTasks: urlSessionTasks)
    let networkProvider = NetworkAdapter(withSession: urlSession)
    let twilioVerify = try! TwilioVerifyBuilder()
                            .setURL(Constants.url)
                            .setNetworkProvider(networkProvider)
                            .setClearStorageOnReinstall(true)
                            .enableDefaultLoggingService(withLevel: .all)
                            .build()
    let expectedError = TwilioVerifyError.inputError(error: TestError.operationFailed as NSError)
    var error: TwilioVerifyError!
    twilioVerify.updateChallenge(withPayload: Constants.generateUpdateChallengePayload(withFactorSid: factor!.sid), success: {
      XCTFail()
      expectation.fulfill()
    }) { failure in
      error = failure
      expectation.fulfill()
    }
    waitForExpectations(timeout: 3, handler: nil)
    XCTAssertEqual(error.code, expectedError.code, "Error code should be \(expectedError.code) but was \(error.code)")
    XCTAssertEqual(error.localizedDescription, expectedError.localizedDescription,
                   "Error description should be \(expectedError.localizedDescription) but was \(error.localizedDescription)")
  }
  
  func testUpdateChallenge_withInvalidAPIResponseBody_shouldSucceed() {
    let expectation = self.expectation(description: "testUpdateChallenge_withInvalidAPIResponseBody_shouldSucceed")
    guard let pathPendingChallengesString = Bundle(for: type(of: self)).path(forResource: Constants.pendingChallengesValidResponse, ofType: Constants.json),
      let jsonPendingChallengesString = try? String(contentsOfFile: pathPendingChallengesString, encoding: .utf8),
      let jsonPendingChallengesData = jsonPendingChallengesString.data(using: .utf8),
      let jsonPendingChallengesDictionary = try? JSONSerialization.jsonObject(with: jsonPendingChallengesData, options: []) as? [String: Any] else {
        fatalError("get_challenge_pending_valid_response.json not found")
    }
    guard let pathApprovedChallengesString = Bundle(for: type(of: self)).path(forResource: Constants.invalidResponse, ofType: Constants.json),
      let jsonApprovedChallengesString = try? String(contentsOfFile: pathApprovedChallengesString, encoding: .utf8),
      let jsonApprovedChallengesData = jsonApprovedChallengesString.data(using: .utf8) else {
        fatalError("invalid_response.json not found")
    }
    let headers = jsonPendingChallengesDictionary.keys.map { String($0) }.joined(separator: ChallengeMapper.Constants.signatureFieldsHeaderSeparator)
    let urlResponse = HTTPURLResponse(url: URL(string: Constants.url)!, statusCode: 200, httpVersion: "", headerFields: [ChallengeRepository.Constants.signatureFieldsHeader: headers])
    let urlSessionTasks = [URLSessionDataTaskMock(data: jsonPendingChallengesData, httpURLResponse: urlResponse, requestError: nil),
                           URLSessionDataTaskMock(data: "".data(using: .utf8), httpURLResponse: urlResponse, requestError: nil),
                           URLSessionDataTaskMock(data: jsonApprovedChallengesData, httpURLResponse: urlResponse, requestError: nil)]
    let urlSession = URLSessionMock(urlSessionDataTasks: urlSessionTasks)
    let networkProvider = NetworkAdapter(withSession: urlSession)
    let twilioVerify = try! TwilioVerifyBuilder()
                            .setURL(Constants.url)
                            .setNetworkProvider(networkProvider)
                            .setClearStorageOnReinstall(true)
                            .enableDefaultLoggingService(withLevel: .all)
                            .build()
    let expectedError = TwilioVerifyError.inputError(error: TestError.operationFailed as NSError)
    var error: TwilioVerifyError!
    twilioVerify.updateChallenge(withPayload: Constants.generateUpdateChallengePayload(withFactorSid: factor!.sid), success: {
      XCTFail()
      expectation.fulfill()
    }) { failure in
      error = failure
      expectation.fulfill()
    }
    waitForExpectations(timeout: 3, handler: nil)
    XCTAssertEqual(error.code, expectedError.code, "Error code should be \(expectedError.code) but was \(error.code)")
    XCTAssertEqual(error.localizedDescription, expectedError.localizedDescription,
                   "Error description should be \(expectedError.localizedDescription) but was \(error.localizedDescription)")
  }
}

private extension UpdateChallengeTests {
  struct Constants {
    static let challengeSid = "challengeSid"
    static let status = ChallengeStatus.approved
    static let url = "https://twilio.com"
    static let pendingChallengesValidResponse = "get_challenge_pending_valid_response"
    static let approvedChallengesValidResponse = "get_challenge_approved_valid_response"
    static let invalidResponse = "invalid_response"
    static let json = "json"
    static let statusKey = "status"
    static let hiddenDetailsKey = "hidden_details"
    static let sidKey = "sid"
    static let factorSidKey = "factor_sid"
    static func generateUpdateChallengePayload(withFactorSid factorSid: String) -> UpdatePushChallengePayload {
      UpdatePushChallengePayload(factorSid: factorSid, challengeSid: Constants.challengeSid, status: status)
    }
  }
}
