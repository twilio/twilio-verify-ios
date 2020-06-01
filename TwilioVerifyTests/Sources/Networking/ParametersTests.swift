//
//  ParametersTests.swift
//  TwilioVerifyTests
//
//  Created by Sergio Fierro on 6/1/20.
//  Copyright © 2020 Twilio. All rights reserved.
//

import XCTest
@testable import TwilioVerify

class ParametersTests: XCTestCase {

  func testParameters_asString_shouldReturnExpectedEncodedParameters() {
    let key1 = "key1"
    let value1 = "^&value1"
    let key2 = "key2"
    let value2 = 12345
    let expectedParameters = [Parameter(name: key1, value: value1), Parameter(name: key2, value: value2)]
    let expectedStringParameters = "\(key1.addingPercentEncoding(withAllowedCharacters: .customURLQueryAllowed) ?? "")=\(value1.addingPercentEncoding(withAllowedCharacters: .customURLQueryAllowed) ?? "")&\(key2.addingPercentEncoding(withAllowedCharacters: .customURLQueryAllowed) ?? "")=\(String(value2).addingPercentEncoding(withAllowedCharacters: .customURLQueryAllowed) ?? "")"
    
    var parameters = Parameters()
    parameters.addAll(expectedParameters)
    
    let stringParameters = parameters.asString()
    XCTAssertEqual(expectedStringParameters, stringParameters,
                   "String parameters should be \(expectedStringParameters) but were \(String(describing: stringParameters))")
  }
  
  func testParameters_asData_shouldReturnExpectedParameters() {
    let key1 = "key1"
    let value1 = "value1"
    let key2 = "key2"
    let value2 = 12345
    let expectedParameters = [Parameter(name: key1, value: value1), Parameter(name: key2, value: value2)]
    
    var parameters = Parameters()
    parameters.addAll(expectedParameters)
    
    var data: Data!
    XCTAssertNoThrow(data = try parameters.asData(), "Parameters as data should not throw")
    var body: [String: Any]!
    XCTAssertNoThrow(body = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any])
    XCTAssertEqual(value1, body[key1] as! String,
                   "Value should be \(value1) at \(key1) but was \(String(describing: body[key1]))")
    XCTAssertEqual(value2, body[key2] as! Int,
                   "Value should be \(value2) at \(key2) but was \(String(describing: body[key2]))")
  }
  
  func testUpdateParameters_shouldUpdateValueForSpecificKey() {
    let key1 = "key1"
    let value1 = "value1"
    let key2 = "key2"
    var value2 = 12345
    let expectedParameters = [Parameter(name: key1, value: value1), Parameter(name: key2, value: value2)]
    
    var parameters = Parameters()
    parameters.addAll(expectedParameters)
    
    var data: Data!
    XCTAssertNoThrow(data = try parameters.asData(), "Parameters as data should not throw")
    var body: [String: Any]!
    XCTAssertNoThrow(body = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any])
    XCTAssertEqual(value1, body[key1] as! String,
                   "Value should be \(value1) at \(key1) but was \(String(describing: body[key1]))")
    XCTAssertEqual(value2, body[key2] as! Int,
                   "Value should be \(value2) at \(key2) but was \(String(describing: body[key2]))")
    
    value2 = 54321
    parameters.addAll([Parameter(name: key1, value: value2)])
    
    
    XCTAssertNoThrow(data = try parameters.asData(), "Parameters as data should not throw")
    XCTAssertNoThrow(body = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any])
    XCTAssertEqual(value2, body[key1] as! Int,
                   "Value should be \(value2) at \(key1) but was \(String(describing: body[key1]))")
    XCTAssertEqual(value2, body[key1] as! Int,
                   "Value should be \(value2) at \(key1) but was \(String(describing: body[key1]))")
  }
  
  func testParameters_withListValue_shouldReturnExpectedStringParams() {
    let key1 = "key1"
    let value1 = "value1"
    let key2 = "key2"
    let value2 = ["123", "321", "456"]
    let expectedParameters = [Parameter(name: key1, value: value1), Parameter(name: key2, value: value2)]
    
    var expectedStringParameters = "\(key1.addingPercentEncoding(withAllowedCharacters: .customURLQueryAllowed) ?? "")=\(value1.addingPercentEncoding(withAllowedCharacters: .customURLQueryAllowed) ?? "")"
    value2.forEach{value in
      expectedStringParameters += "&\(key2)[]=\(value)".addingPercentEncoding(withAllowedCharacters: .customURLQueryAllowed) ?? ""
    }
    var parameters = Parameters()
    parameters.addAll(expectedParameters)
    
    let stringParameters = parameters.asString()
    XCTAssertEqual(expectedStringParameters, stringParameters,
                   "String parameters should be \(expectedStringParameters) but were \(String(describing: stringParameters))")
  }
}
