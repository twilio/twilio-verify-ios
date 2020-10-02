//
//  CreateFactorTests.swift
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

// swiftlint:disable force_cast force_try
class CreateFactorTests: XCTestCase {

  func testCreateFactor_withValidAPIResponse_shouldReturnFactor() {
    guard let pathString = Bundle(for: type(of: self)).path(forResource: Constants.createFactorValidResponse, ofType: Constants.json),
      let jsonString = try? String(contentsOfFile: pathString, encoding: .utf8),
      let jsonData = jsonString.data(using: .utf8),
      let jsonDictionary = try? JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any] else {
      fatalError("create_factor_valid_response.json not found")
    }
    let expectation = self.expectation(description: "testCreateFactor_withValidAccessTokenAndValidAPIResponse_shouldReturnFactor")
    let urlResponse = HTTPURLResponse(url: URL(string: Constants.url)!, statusCode: 200, httpVersion: "", headerFields: nil)
    let urlSession = URLSessionMock(data: jsonData, httpURLResponse: urlResponse, error: nil)
    let networkProvider = NetworkAdapter(withSession: urlSession)
    let twilioVerify = try! TwilioVerifyBuilder()
                            .setURL(Constants.url)
                            .setNetworkProvider(networkProvider)
                            .setClearStorageOnReinstall(true)
                            .setLogLevel(.off)
                            .build()
    var factor: Factor!
    twilioVerify.createFactor(withPayload: Constants.factorPayload, success: { response in
      factor = response
      expectation.fulfill()
    }) { _ in
      XCTFail()
      expectation.fulfill()
    }
    waitForExpectations(timeout: 3, handler: nil)
    XCTAssertTrue(factor is PushFactor, "Factor should be PushFactor")
    XCTAssertNotNil((factor as! PushFactor).keyPairAlias, "Factor key pair alias should exists")
    XCTAssertEqual(factor.friendlyName, Constants.friendlyName,
                   "Factor friendly name should be \(Constants.friendlyName) but was \(factor.friendlyName)")
    XCTAssertEqual(factor.sid, jsonDictionary[Constants.sidKey] as! String,
                   "Factor sid should be \(jsonDictionary[Constants.sidKey] as! String) but was \(factor.sid)")
    XCTAssertEqual(factor.accountSid, jsonDictionary[Constants.accountSidKey] as! String,
                   "Factor account sid should be \(jsonDictionary[Constants.accountSidKey] as! String) but was \(factor.accountSid)")
    XCTAssertEqual(factor.type.rawValue, jsonDictionary[Constants.factorTypeKey] as! String,
                   "Factor type should be \(jsonDictionary[Constants.factorStatusKey] as! String) but was \(factor.type.rawValue)")
    XCTAssertEqual(factor.status.rawValue, jsonDictionary[Constants.factorStatusKey] as! String,
                   "Factor status should be \(jsonDictionary[Constants.factorStatusKey] as! String) but was \(factor.status.rawValue)")
    XCTAssertEqual(factor.identity, Constants.identity,
                   "Factor identity should be \(Constants.identity) but was \(factor.identity)")
    XCTAssertEqual(factor.serviceSid, Constants.serviceSid,
                   "Factor service sid should be \(Constants.serviceSid) but was \(factor.serviceSid)")
  }
  
  func testCreateFactor_withInvalidAPIResponseCode_shouldFail() {
    guard let pathString = Bundle(for: type(of: self)).path(forResource: Constants.createFactorValidResponse, ofType: Constants.json),
      let jsonString = try? String(contentsOfFile: pathString, encoding: .utf8),
      let jsonData = jsonString.data(using: .utf8) else {
        fatalError("create_factor_valid_response.json not found")
    }
    
    let expectation = self.expectation(description: "testCreateFactor_withValidAccessTokenAndInvalidAPIResponseCode_shouldFail")
    let urlResponse = HTTPURLResponse(url: URL(string: Constants.url)!, statusCode: 400, httpVersion: "", headerFields: nil)
    let urlSession = URLSessionMock(data: jsonData, httpURLResponse: urlResponse, error: nil)
    let networkProvider = NetworkAdapter(withSession: urlSession)
    let twilioVerify = try! TwilioVerifyBuilder()
                            .setURL(Constants.url)
                            .setNetworkProvider(networkProvider)
                            .setClearStorageOnReinstall(true)
                            .setLogLevel(.off)
                            .build()
    let expectedError = TwilioVerifyError.networkError(error: TestError.operationFailed as NSError)
    var error: TwilioVerifyError!
    twilioVerify.createFactor(withPayload: Constants.factorPayload, success: { _ in
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
  
  func testCreateFactor_withInvalidAPIResponseBody_shouldFail() {
    guard let pathString = Bundle(for: type(of: self)).path(forResource: Constants.createFactorInvalidResponse, ofType: Constants.json),
      let jsonString = try? String(contentsOfFile: pathString, encoding: .utf8),
      let jsonData = jsonString.data(using: .utf8) else {
        fatalError("invalid_response.json not found")
    }
    
    let expectation = self.expectation(description: "testCreateFactor_withValidAccessTokenAndInvalidAPIResponseBody_shouldFail")
    let urlResponse = HTTPURLResponse(url: URL(string: Constants.url)!, statusCode: 200, httpVersion: "", headerFields: nil)
    let urlSession = URLSessionMock(data: jsonData, httpURLResponse: urlResponse, error: nil)
    let networkProvider = NetworkAdapter(withSession: urlSession)
    let twilioVerify = try! TwilioVerifyBuilder()
                            .setURL(Constants.url)
                            .setNetworkProvider(networkProvider)
                            .setClearStorageOnReinstall(true)
                            .setLogLevel(.off)
                            .build()
    let expectedError = TwilioVerifyError.networkError(error: TestError.operationFailed as NSError)
    var error: TwilioVerifyError!
    twilioVerify.createFactor(withPayload: Constants.factorPayload, success: { _ in
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

private extension CreateFactorTests {
  struct Constants {
    static let url = "https://twilio.com"
    static let accountSidKey = "account_sid"
    static let sidKey = "sid"
    static let factorStatusKey = "status"
    static let factorTypeKey = "factor_type"
    static let friendlyName = "friendlyName"
    static let identity = "identity"
    static let serviceSid = "serviceSid"
    static let pushToken = "pushToken"
    static let createFactorValidResponse = "create_factor_valid_response"
    static let createFactorInvalidResponse = "invalid_response"
    static let json = "json"
    static let accessToken = """
              eyJjdHkiOiJ0d2lsaW8tZnBhO3Y9MSIsInR5cCI6IkpXVCIsImFsZyI6IkhTMjU2In0.eyJpc3MiOiJTSz
              AwMTBjZDc5Yzk4NzM1ZTBjZDliYjQ5NjBlZjYyZmI4IiwiZXhwIjoxNTgzOTM3NjY0LCJncmFudHMiOnsidmVyaW
              Z5Ijp7ImlkZW50aXR5IjoiWUViZDE1NjUzZDExNDg5YjI3YzFiNjI1NTIzMDMwMTgxNSIsImZhY3RvciI6InB1c2
              giLCJyZXF1aXJlLWJpb21ldHJpY3MiOnRydWV9LCJhcGkiOnsiYXV0aHlfdjEiOlt7ImFjdCI6WyJjcmVhdGUiXS
              wicmVzIjoiL1NlcnZpY2VzL0lTYjNhNjRhZTBkMjI2MmEyYmFkNWU5ODcwYzQ0OGI4M2EvRW50aXRpZXMvWUViZD
              E1NjUzZDExNDg5YjI3YzFiNjI1NTIzMDMwMTgxNS9GYWN0b3JzIn1dfX0sImp0aSI6IlNLMDAxMGNkNzljOTg3Mz
              VlMGNkOWJiNDk2MGVmNjJmYjgtMTU4Mzg1MTI2NCIsInN1YiI6IkFDYzg1NjNkYWY4OGVkMjZmMjI3NjM4ZjU3Mz
              g3MjZmYmQifQ.R01YC9mfCzIf9W81GUUCMjTwnhzIIqxV-tcdJYuy6kA
              """
    static let factorPayload = PushFactorPayload(
      friendlyName: Constants.friendlyName,
      serviceSid: Constants.serviceSid,
      identity: Constants.identity,
      pushToken: Constants.pushToken,
      accessToken: Constants.accessToken)
  }
}
