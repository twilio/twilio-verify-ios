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
  
  private func userAgentHeader() -> HttpHeader {
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
    return HttpHeader.userAgent(userAgent)
  }
  
  public func commonHeaders(httpMethod: HttpMethod) -> [HttpHeader] {
    var commonHeaders = [userAgentHeader(), authorization.header()]
    switch httpMethod {
      case .post,
           .put,
           .delete:
        commonHeaders.append(HttpHeader.accept(MediaType.json.value))
        commonHeaders.append(HttpHeader.contentType(MediaType.urlEncoded.value))
      case .get:
        commonHeaders.append(HttpHeader.accept(MediaType.urlEncoded.value))
        commonHeaders.append(HttpHeader.contentType(MediaType.urlEncoded.value))
    }
    return commonHeaders
  }
}

extension RequestHelper {
  struct Constants {
    static let platform = "iOS"
  }
}

public struct HttpHeader: Hashable {
  
  public let name: String
  public let value: String
  
  init(name: String, value: String) {
    self.name = name
    self.value = value
  }
}

extension HttpHeader: CustomStringConvertible {
  public var description: String {
    "\(name): \(value)"
  }
}

extension HttpHeader {
  
  public static func accept(_ value: String) -> HttpHeader {
    HttpHeader(name: "Accept", value: value)
  }
  
  public static func contentType(_ value: String) -> HttpHeader {
    HttpHeader(name: "Content-Type", value: value)
  }
  
  public static func userAgent(_ value: String) -> HttpHeader {
    HttpHeader(name: "User-Agent", value: value)
  }
  
  public static func authorization(username: String, password: String) -> HttpHeader {
    let credential = Data("\(username):\(password)".utf8).base64EncodedString()
    
    return authorization("Basic \(credential)")
  }
  
  public static func authorization(bearerToken: String) -> HttpHeader {
    authorization("Bearer \(bearerToken)")
  }

  public static func authorization(_ value: String) -> HttpHeader {
    HttpHeader(name: "Authorization", value: value)
  }
}
