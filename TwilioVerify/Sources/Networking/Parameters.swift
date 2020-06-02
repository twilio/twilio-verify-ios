//
//  Parameters.swift
//  TwilioVerify
//
//  Created by Sergio Fierro on 5/29/20.
//  Copyright © 2020 Twilio. All rights reserved.
//

import Foundation

struct Parameters {
  private var parameters: [Parameter] = []
  
  mutating func addAll(_ parameters: [Parameter]) {
    parameters.forEach{ add($0)}
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
      throw(NetworkError.invalidBody)
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
