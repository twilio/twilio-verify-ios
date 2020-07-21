//
//  BaseFactorTests.swift
//  TwilioVerifyTests
//
//  Created by Sergio Fierro on 7/16/20.
//  Copyright © 2020 Twilio. All rights reserved.
//

import XCTest
@testable import TwilioVerify

internal class BaseFactorTests: XCTestCase {
  
  var factor: PushFactor?
  
  override func setUpWithError() throws {
    try super.setUpWithError()
    createFactor()
  }
  
  func createFactor() {
    guard let pathString = Bundle(for: type(of: self)).path(forResource: "create_factor_valid_response", ofType: "json"),
      let jsonString = try? String(contentsOfFile: pathString, encoding: .utf8),
      let jsonData = jsonString.data(using: .utf8) else {
        fatalError("create_factor_valid_response.json not found")
    }
    let expectation = self.expectation(description: "createFactor")
    let urlResponse = HTTPURLResponse(url: URL(string: "https://twilio.com")!, statusCode: 200, httpVersion: "", headerFields: nil)
    let urlSession = URLSessionMock(data: jsonData, httpURLResponse: urlResponse, error: nil)
    let networkProvider = NetworkAdapter(withSession: urlSession)
    let twilioVerify = TwilioVerifyBuilder().setURL("https://twilio.com").setNetworkProvider(networkProvider).build()
    let jwe = """
              eyJjdHkiOiJ0d2lsaW8tZnBhO3Y9MSIsInR5cCI6IkpXVCIsImFsZyI6IkhTMjU2In0.eyJpc3MiOiJTSz
              AwMTBjZDc5Yzk4NzM1ZTBjZDliYjQ5NjBlZjYyZmI4IiwiZXhwIjoxNTgzOTM3NjY0LCJncmFudHMiOnsidmVyaW
              Z5Ijp7ImlkZW50aXR5IjoiWUViZDE1NjUzZDExNDg5YjI3YzFiNjI1NTIzMDMwMTgxNSIsImZhY3RvciI6InB1c2
              giLCJyZXF1aXJlLWJpb21ldHJpY3MiOnRydWV9LCJhcGkiOnsiYXV0aHlfdjEiOlt7ImFjdCI6WyJjcmVhdGUiXS
              wicmVzIjoiL1NlcnZpY2VzL0lTYjNhNjRhZTBkMjI2MmEyYmFkNWU5ODcwYzQ0OGI4M2EvRW50aXRpZXMvWUViZD
              E1NjUzZDExNDg5YjI3YzFiNjI1NTIzMDMwMTgxNS9GYWN0b3JzIn1dfX0sImp0aSI6IlNLMDAxMGNkNzljOTg3Mz
              VlMGNkOWJiNDk2MGVmNjJmYjgtMTU4Mzg1MTI2NCIsInN1YiI6IkFDYzg1NjNkYWY4OGVkMjZmMjI3NjM4ZjU3Mz
              g3MjZmYmQifQ.R01YC9mfCzIf9W81GUUCMjTwnhzIIqxV-tcdJYuy6kA
              """
    let factorPayload = PushFactorPayload(
      friendlyName: "friendlyName",
      serviceSid: "serviceSid",
      identity: "identity",
      pushToken: "pushToken",
      enrollmentJwe: jwe)
    twilioVerify.createFactor(withPayload: factorPayload, success: { factor in
      self.factor = factor as? PushFactor
      expectation.fulfill()
    }) { _ in
      XCTFail()
      expectation.fulfill()
    }
    waitForExpectations(timeout: 3, handler: nil)
  }
}
