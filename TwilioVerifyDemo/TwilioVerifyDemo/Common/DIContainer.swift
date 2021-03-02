//
//  DIContainer.swift
//  TwilioVerifyDemo
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

protocol DIContainerProtocol {
  func register<Component>(type: Component.Type, component: Any)
  func resolve<Component>(type: Component.Type) -> Component?
}

final class DIContainer: DIContainerProtocol {

  static let shared = DIContainer()
  
  private init() {}

  var components: [String: Any] = [:]

  func register<Component>(type: Component.Type, component: Any) {
    components["\(type)"] = component
  }

  func resolve<Component>(type: Component.Type) -> Component? {
    return components["\(type)"] as? Component
  }
}
