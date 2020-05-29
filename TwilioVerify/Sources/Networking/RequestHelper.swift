//
//  RequestHelper.swift
//  TwilioVerify
//
//  Created by Sergio Fierro on 5/29/20.
//  Copyright © 2020 Twilio. All rights reserved.
//

import Foundation
import UIKit

public class RequestHelper {
  
  private let appInfo: [String: Any]?
  private let frameworkDict: [String: Any]?
  private let authorization: BasicAuthorization
  
  public required init(authorization: BasicAuthorization, appInfo: [String: Any]? = Bundle.main.infoDictionary) {
    self.authorization = authorization
    self.appInfo = appInfo
    self.frameworkDict = Bundle(for: type(of: self)).infoDictionary
  }
  
  private func userAgentHeader() -> HTTPHeader {
    let separator = "; "
    let appName = appInfo?["CFBundleName"] as? String ?? "unknown"
    let appVersionName = appInfo?["CFBundleShortVersionString"] as? String ?? "unknown"
    let appBuildCode = appInfo?["CFBundleVersion"] as? String ?? "unknown"
    let osVersion = "\(Constants.platform) \(UIDevice.current.systemVersion)"
    let device = UIDevice.current.model
    let sdkName = frameworkDict?["CFBundleName"] as? String ?? "unknown"
    let sdkVersionName = frameworkDict?["CFBundleShortVersionString"] as? String ?? "unknown"
    let sdkBuildCode = frameworkDict?["CFBundleVersion"] as? String ?? "unknown"
    let userAgent = [appName, Constants.platform, appVersionName, appBuildCode, osVersion, device, sdkName, sdkVersionName, sdkBuildCode].joined(separator: separator)
    return HTTPHeader.userAgent(userAgent)
  }
  
  public func commonHeaders(httpMethod: HTTPMethod) -> [HTTPHeader] {
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
    static let platform = "iOS"
  }
}
