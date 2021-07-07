//
//  ParametersTests.swift
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
@testable import TwilioVerifySDK

// swiftlint:disable force_cast
class ParametersTests: XCTestCase {

  func testParameters_asString_shouldReturnExpectedEncodedParameters() {
    let key1 = Contants.key1
    let value1 = "^&\(Contants.value1)"
    let key2 = Contants.key2
    let value2 = 12345
    let expectedParameters = [Parameter(name: key1, value: value1), Parameter(name: key2, value: value2)]
    let expectedStringParameters = "\(key1.addingPercentEncoding(withAllowedCharacters: .customURLQueryAllowed) ?? "")" +
                                   "=\(value1.addingPercentEncoding(withAllowedCharacters: .customURLQueryAllowed) ?? "")" +
                                   "&\(key2.addingPercentEncoding(withAllowedCharacters: .customURLQueryAllowed) ?? "")" +
                                   "=\(String(value2).addingPercentEncoding(withAllowedCharacters: .customURLQueryAllowed) ?? "")"
    
    var parameters = Parameters()
    parameters.addAll(expectedParameters)
    
    let stringParameters = parameters.asString()
    XCTAssertEqual(stringParameters, expectedStringParameters,
                   "String parameters should be \(expectedStringParameters) but were \(String(describing: stringParameters))")
  }
  
  func testParameters_asData_shouldReturnExpectedParameters() {
    let key1 = Contants.key1
    let value1 = Contants.value1
    let key2 = Contants.key2
    let value2 = Contants.value2
    let expectedParameters = [Parameter(name: key1, value: value1), Parameter(name: key2, value: value2)]
    
    var parameters = Parameters()
    parameters.addAll(expectedParameters)
    
    var data: Data!
    XCTAssertNoThrow(data = try parameters.asData(), "Parameters as data should not throw")
    var body: [String: Any]!
    XCTAssertNoThrow(body = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any])
    XCTAssertEqual(body[key1] as! String, value1,
                   "Value should be \(value1) at \(key1) but was \(String(describing: body[key1]))")
    XCTAssertEqual(body[key2] as! Int, value2,
                   "Value should be \(value2) at \(key2) but was \(String(describing: body[key2]))")
  }
  
  func testUpdateParameters_shouldUpdateValueForSpecificKey() {
    let key1 = Contants.key1
    let value1 = Contants.value1
    let key2 = Contants.key2
    var value2 = Contants.value2
    let expectedParameters = [Parameter(name: key1, value: value1), Parameter(name: key2, value: value2)]
    
    var parameters = Parameters()
    parameters.addAll(expectedParameters)
    
    var data: Data!
    XCTAssertNoThrow(data = try parameters.asData(), "Parameters as data should not throw")
    var body: [String: Any]!
    XCTAssertNoThrow(body = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any])
    XCTAssertEqual(body[key1] as! String, value1,
                   "Value should be \(value1) at \(key1) but was \(String(describing: body[key1]))")
    XCTAssertEqual(body[key2] as! Int, value2,
                   "Value should be \(value2) at \(key2) but was \(String(describing: body[key2]))")
    
    value2 = 54321
    parameters.addAll([Parameter(name: key1, value: value2)])
    
    XCTAssertNoThrow(data = try parameters.asData(), "Parameters as data should not throw")
    XCTAssertNoThrow(body = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any])
    XCTAssertEqual(body[key1] as! Int, value2,
                   "Value should be \(value2) at \(key1) but was \(String(describing: body[key1]))")
    XCTAssertEqual(body[key1] as! Int, value2,
                   "Value should be \(value2) at \(key1) but was \(String(describing: body[key1]))")
  }
  
  func testParameters_withListValue_shouldReturnExpectedStringParams() {
    let key1 = Contants.key1
    let value1 = Contants.value1
    let key2 = Contants.key2
    let value2 = ["123", "321", "456"]
    let expectedParameters = [Parameter(name: key1, value: value1), Parameter(name: key2, value: value2)]
    var expectedStringParameters = "\(key1.addingPercentEncoding(withAllowedCharacters: .customURLQueryAllowed) ?? "")" +
                                   "=\(value1.addingPercentEncoding(withAllowedCharacters: .customURLQueryAllowed) ?? "")"
    
    value2.forEach {
      expectedStringParameters += "&\(key2)[]=\($0)".addingPercentEncoding(withAllowedCharacters: .customURLQueryAllowed) ?? ""
    }
    
    var parameters = Parameters()
    parameters.addAll(expectedParameters)
    
    let stringParameters = parameters.asString()
    XCTAssertEqual(stringParameters, expectedStringParameters,
                   "String parameters should be \(expectedStringParameters) but were \(String(describing: stringParameters))")
  }
}

extension ParametersTests {
  struct Contants {
    static let key1 = "key1"
    static let key2 = "key2"
    static let value1 = "value1"
    static let value2 = 12345
  }
}
