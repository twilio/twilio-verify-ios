//
//  RequestHelper.swift
//  TwilioVerify
//
//  Copyright © 2020 Twilio. All rights reserved.
//  This file is licensed under the Apache License 2.0.
//  License text available at https://github.com/twilio/twilio-verify-ios/blob/main/LICENSE
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
