//
//  GetChallengeTests.swift
//  TwilioVerifyTests
//
//  Created by Sergio Fierro on 7/16/20.
//  Copyright © 2020 Twilio. All rights reserved.
//

import XCTest
@testable import TwilioVerify

// swiftlint:disable force_cast
class GetChallengeTests: BaseFactorTests {

  func testGetChallenge_withValidAPIResponse_shouldSucceed() {
    guard let pathString = Bundle(for: type(of: self)).path(forResource: Constants.pendingChallengesValidResponse, ofType: Constants.json),
      let jsonString = try? String(contentsOfFile: pathString, encoding: .utf8),
      let jsonData = jsonString.data(using: .utf8),
      let jsonDictionary = try? JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any] else {
        fatalError("get_challenge_pending_valid_response.json not found")
    }
    let expectation = self.expectation(description: "testGetChallenge_withValidAPIResponse_shouldSucceed")
    let urlResponse = HTTPURLResponse(url: URL(string: Constants.url)!, statusCode: 200, httpVersion: "", headerFields: nil)
    let urlSession = URLSessionMock(data: jsonData, httpURLResponse: urlResponse, error: nil)
    let networkProvider = NetworkAdapter(withSession: urlSession)
    let twilioVerify = try! TwilioVerifyBuilder().setURL(Constants.url).setNetworkProvider(networkProvider).build()
    var challenge: Challenge!
    twilioVerify.getChallenge(challengeSid: Constants.challengeSid, factorSid: factor!.sid, success: { response in
      challenge = response
      expectation.fulfill()
    }) { _ in
      XCTFail()
      expectation.fulfill()
    }
    waitForExpectations(timeout: 3, handler: nil)
    XCTAssertEqual(challenge.sid, jsonDictionary[Constants.sidKey] as! String,
                   "Challenge sid should be \(jsonDictionary[Constants.sidKey] as! String) but was \(challenge.sid)")
    XCTAssertEqual(challenge.factorSid, jsonDictionary[Constants.factorSidKey] as! String,
                   "Factor sid should be \(jsonDictionary[Constants.factorSidKey] as! String) but was \(challenge.factorSid)")
    XCTAssertEqual(challenge.hiddenDetails, jsonDictionary[Constants.hiddenDetailsKey] as! String,
                   "Challenge hidden details should be \(jsonDictionary[Constants.hiddenDetailsKey] as! String) but was \(challenge.hiddenDetails)")
    XCTAssertEqual(challenge.status.rawValue, jsonDictionary[Constants.statusKey] as! String,
                   "Challenge status should be \(jsonDictionary[Constants.statusKey] as! String) but was \(challenge.status.rawValue)")
  }
  
  func testGetChallenge_withInvalidAPIResponseBody_shouldFail() {
    guard let pathString = Bundle(for: type(of: self)).path(forResource: Constants.invalidResponse, ofType: Constants.json),
      let jsonString = try? String(contentsOfFile: pathString, encoding: .utf8),
      let jsonData = jsonString.data(using: .utf8) else {
        fatalError("invalid_response.json not found")
    }
    
    let expectation = self.expectation(description: "testGetChallenge_withInvalidAPIResponseBody_shouldFail")
    let urlResponse = HTTPURLResponse(url: URL(string: Constants.url)!, statusCode: 200, httpVersion: "", headerFields: nil)
    let urlSession = URLSessionMock(data: jsonData, httpURLResponse: urlResponse, error: nil)
    let networkProvider = NetworkAdapter(withSession: urlSession)
    let twilioVerify = try! TwilioVerifyBuilder().setURL(Constants.url).setNetworkProvider(networkProvider).build()
    let expectedError = TwilioVerifyError.inputError(error: TestError.operationFailed as NSError)
    var error: TwilioVerifyError!
    twilioVerify.getChallenge(challengeSid: Constants.challengeSid, factorSid: factor!.sid, success: { _ in
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
  
  func testGetChallenge_withInvalidAPIResponseCode_shouldFail() {
    guard let pathString = Bundle(for: type(of: self)).path(forResource: Constants.pendingChallengesValidResponse, ofType: Constants.json),
      let jsonString = try? String(contentsOfFile: pathString, encoding: .utf8),
      let jsonData = jsonString.data(using: .utf8) else {
        fatalError("get_challenge_pending_valid_response.json not found")
    }
    
    let expectation = self.expectation(description: "testGetChallenge_withInvalidAPIResponseCode_shouldFail")
    let urlResponse = HTTPURLResponse(url: URL(string: Constants.url)!, statusCode: 400, httpVersion: "", headerFields: nil)
    let urlSession = URLSessionMock(data: jsonData, httpURLResponse: urlResponse, error: nil)
    let networkProvider = NetworkAdapter(withSession: urlSession)
    let twilioVerify = try! TwilioVerifyBuilder().setURL(Constants.url).setNetworkProvider(networkProvider).build()
    let expectedError = TwilioVerifyError.inputError(error: TestError.operationFailed as NSError)
    var error: TwilioVerifyError!
    twilioVerify.getChallenge(challengeSid: Constants.challengeSid, factorSid: factor!.sid, success: { _ in
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

private extension GetChallengeTests {
  struct Constants {
    static let challengeSid = "challengeSid"
    static let status = ChallengeStatus.approved
    static let url = "https://twilio.com"
    static let pendingChallengesValidResponse = "get_challenge_pending_valid_response"
    static let invalidResponse = "invalid_response"
    static let json = "json"
    static let statusKey = "status"
    static let hiddenDetailsKey = "hidden_details"
    static let sidKey = "sid"
    static let factorSidKey = "factor_sid"
  }
}
