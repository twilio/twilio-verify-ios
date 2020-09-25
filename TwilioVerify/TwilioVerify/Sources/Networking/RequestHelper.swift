//
//  RequestHelper.swift
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
import UIKit

class RequestHelper {
  
  private let appInfo: [String: Any]?
  private let frameworkInfo: [String: Any]?
  private let authorization: BasicAuthorization
  
  required init(authorization: BasicAuthorization) {
    self.authorization = authorization
    self.appInfo = Bundle.main.infoDictionary
    self.frameworkInfo = Bundle(for: type(of: self)).infoDictionary
  }
  
  private func userAgentHeader() -> HTTPHeader {
    let appName = appInfo?[Constants.bundleName] as? String ?? Constants.unknown
    let appVersionName = appInfo?[Constants.bundleShortVersionString] as? String ?? Constants.unknown
    let appBuildCode = appInfo?[Constants.bundleVersion] as? String ?? Constants.unknown
    let osVersion = "\(Constants.platform) \(UIDevice.current.systemVersion)"
    let device = UIDevice.current.model
    let sdkName = frameworkInfo?[Constants.bundleName] as? String ?? Constants.unknown
    let sdkVersionName = frameworkInfo?[Constants.bundleShortVersionString] as? String ?? Constants.unknown
    let sdkBuildCode = frameworkInfo?[Constants.bundleVersion] as? String ?? Constants.unknown
    
    let userAgent = [appName, Constants.platform, appVersionName, appBuildCode, osVersion, device, sdkName, sdkVersionName, sdkBuildCode].joined(separator: Constants.separator)
    return HTTPHeader.userAgent(userAgent)
  }
  
  func commonHeaders(httpMethod: HTTPMethod) -> [HTTPHeader] {
    var commonHeaders = [userAgentHeader(), authorization.header()]
    switch httpMethod {
      case .post,
           .put,
           .delete:
        commonHeaders.append(HTTPHeader.accept(MediaType.json.value))
        commonHeaders.append(HTTPHeader.contentType(MediaType.urlEncoded.value))
      case .get:
        commonHeaders.append(HTTPHeader.accept(MediaType.urlEncoded.value))
        commonHeaders.append(HTTPHeader.contentType(MediaType.urlEncoded.value))
    }
    return commonHeaders
  }
}

extension RequestHelper {
  struct Constants {
    static let separator = "; "
    static let bundleName = "CFBundleName"
    static let bundleShortVersionString = "CFBundleShortVersionString"
    static let bundleVersion = "CFBundleVersion"
    static let unknown = "unknown"
    static let platform = "iOS"
  }
}
