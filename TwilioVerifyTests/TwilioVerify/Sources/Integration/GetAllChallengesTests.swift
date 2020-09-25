//
//  GetAllChallengesTests.swift
//  TwilioVerifyTests
//
//  Copyright © 2020 Twilio. All rights reserved.
//  This file is licensed under the Apache License 2.0.
//  License text available at https://github.com/twilio/twilio-verify-ios/blob/main/LICENSE
//

import XCTest
@testable import TwilioVerify

// swiftlint:disable force_cast force_try
class GetAllChallengesTests: BaseFactorTests {

  func testGetAllChallenges_withValidAPIResponse_shouldSucceed() {
    guard let pathString = Bundle(for: type(of: self)).path(forResource: Constants.getChallengesValidResponse, ofType: Constants.json),
      let jsonString = try? String(contentsOfFile: pathString, encoding: .utf8),
      let jsonData = jsonString.data(using: .utf8),
      let jsonDictionary = try? JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any] else {
        fatalError("get_challenges_valid_response.json not found")
    }
    let expectation = self.expectation(description: "testGetAllChallenges_withValidAPIResponse_shouldSucceed")
    let urlResponse = HTTPURLResponse(url: URL(string: Constants.url)!, statusCode: 200, httpVersion: "", headerFields: nil)
    let urlSession = URLSessionMock(data: jsonData, httpURLResponse: urlResponse, error: nil)
    let networkProvider = NetworkAdapter(withSession: urlSession)
    let twilioVerify = try! TwilioVerifyBuilder().setURL(Constants.url).setNetworkProvider(networkProvider).build()
    var challengeList: ChallengeList!
    twilioVerify.getAllChallenges(withPayload: Constants.generateChallengeListPayload(withFactorSid: factor!.sid), success: { response in
      challengeList = response
      expectation.fulfill()
    }) { _ in
      XCTFail()
      expectation.fulfill()
    }
    waitForExpectations(timeout: 3, handler: nil)
    XCTAssertEqual(challengeList.challenges.count, (jsonDictionary[Constants.challengesKey] as! [Any]).count,
                   "Challenges count should be \((jsonDictionary[Constants.challengesKey] as! [Any]).count) but was \(challengeList.challenges.count)")
    XCTAssertEqual(challengeList!.metadata.pageSize, (jsonDictionary[Constants.metaKey] as! [String: Any])[Constants.pageSizeKey] as! Int,
                   "Challenges metadata page size should be \((jsonDictionary[Constants.metaKey] as! [String: Any])[Constants.pageSizeKey] as! Int) but was \(challengeList.metadata.pageSize)")
    XCTAssertEqual(challengeList.metadata.page, (jsonDictionary[Constants.metaKey] as! [String: Any])[Constants.pageKey] as! Int,
                   "Challenges count should be \((jsonDictionary[Constants.metaKey] as! [String: Any])[Constants.pageKey] as! Int) but was \(challengeList.metadata.page)")
    XCTAssertNotNil(challengeList.metadata.nextPageToken, "Next page token should exists")
    XCTAssertNotNil(challengeList.metadata.previousPageToken, "Previous page token should exists")
  }
  
  func testGetAllChallenges_withInvalidAPIResponseBody_shouldFail() {
    guard let pathString = Bundle(for: type(of: self)).path(forResource: Constants.invalidResponse, ofType: Constants.json),
      let jsonString = try? String(contentsOfFile: pathString, encoding: .utf8),
      let jsonData = jsonString.data(using: .utf8) else {
        fatalError("invalid_response.json not found")
    }
    
    let expectation = self.expectation(description: "testGetAllChallenges_withInvalidAPIResponseBody_shouldFail")
    let urlResponse = HTTPURLResponse(url: URL(string: Constants.url)!, statusCode: 200, httpVersion: "", headerFields: nil)
    let urlSession = URLSessionMock(data: jsonData, httpURLResponse: urlResponse, error: nil)
    let networkProvider = NetworkAdapter(withSession: urlSession)
    let twilioVerify = try! TwilioVerifyBuilder().setURL(Constants.url).setNetworkProvider(networkProvider).build()
    let expectedError = TwilioVerifyError.networkError(error: TestError.operationFailed as NSError)
    var error: TwilioVerifyError!
    twilioVerify.getAllChallenges(withPayload: Constants.generateChallengeListPayload(withFactorSid: factor!.sid), success: { _ in
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
  
  func testGetAllChallenges_withInvalidAPIResponseCode_shouldFail() {
    guard let pathString = Bundle(for: type(of: self)).path(forResource: Constants.getChallengesValidResponse, ofType: Constants.json),
      let jsonString = try? String(contentsOfFile: pathString, encoding: .utf8),
      let jsonData = jsonString.data(using: .utf8) else {
        fatalError("get_challenges_valid_response.json not found")
    }
    
    let expectation = self.expectation(description: "testGetAllChallenges_withInvalidAPIResponseCode_shouldFail")
    let urlResponse = HTTPURLResponse(url: URL(string: Constants.url)!, statusCode: 400, httpVersion: "", headerFields: nil)
    let urlSession = URLSessionMock(data: jsonData, httpURLResponse: urlResponse, error: nil)
    let networkProvider = NetworkAdapter(withSession: urlSession)
    let twilioVerify = try! TwilioVerifyBuilder().setURL(Constants.url).setNetworkProvider(networkProvider).build()
    let expectedError = TwilioVerifyError.networkError(error: TestError.operationFailed as NSError)
    var error: TwilioVerifyError!
    twilioVerify.getAllChallenges(withPayload: Constants.generateChallengeListPayload(withFactorSid: factor!.sid), success: { _ in
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

private extension GetAllChallengesTests {
  struct Constants {
    static let url = "https://twilio.com"
    static let getChallengesValidResponse = "get_challenges_valid_response"
    static let invalidResponse = "invalid_response"
    static let json = "json"
    static let pageSizeKey = "page_size"
    static let metaKey = "meta"
    static let challengesKey = "challenges"
    static let pageKey = "page"
    static func generateChallengeListPayload(withFactorSid factorSid: String) -> ChallengeListPayload {
      ChallengeListPayload(factorSid: factorSid, pageSize: 20)
    }
  }
}
