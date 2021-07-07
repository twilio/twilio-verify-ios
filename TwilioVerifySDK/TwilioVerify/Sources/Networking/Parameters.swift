//
//  Parameters.swift
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

struct Parameters {
  private var parameters: [Parameter] = []
  
  mutating func addAll(_ parameters: [Parameter]) {
    parameters.forEach { add($0) }
  }
  
  private mutating func add(_ parameter: Parameter) {
    update(parameter)
  }
  
  private mutating func update(_ parameter: Parameter) {
    guard let index = parameters.firstIndex(of: parameter) else {
      parameters.append(parameter)
      return
    }
    
    parameters.replaceSubrange(index...index, with: [parameter])
  }
  
  private var dictionary: [String: Any] {
    let namesAndValues = parameters.map { ($0.name, $0.value) }
    
    return Dictionary(namesAndValues, uniquingKeysWith: { _, last in last })
  }
  
  func asString() -> String {
    var data = [String]()
    parameters.forEach { parameter in
      if let values = parameter.value as? [Any] {
        values.forEach {
          data.append(parameter.name + "[]=\($0)")
        }
      } else {
        data.append(parameter.name + "=\(parameter.value)")
      }
    }
    return data.map { encode(String($0)) }.joined(separator: "&")
  }
  
  private func encode(_ parameter: Any) -> String {
    guard let parameter = parameter as? String else { return String() }
    return parameter.addingPercentEncoding(withAllowedCharacters: .customURLQueryAllowed) ?? ""
  }
  
  func asData() throws -> Data {
    guard let data = try? JSONSerialization.data(withJSONObject: dictionary, options: []) else {
      throw NetworkError.invalidBody
    }
    
    return data
  }
}

struct Parameter: Equatable {
  
  let name: String
  let value: Any
  
  init(name: String, value: Any) {
    self.name = name
    self.value = value
  }
  
  static func == (lhs: Parameter, rhs: Parameter) -> Bool {
    return lhs.name == rhs.name
  }
}
