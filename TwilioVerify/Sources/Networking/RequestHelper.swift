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
  
  private let appDict: [String: Any]?
  private let frameworkDict: [String: Any]?
  
  public required init(appBundle: Bundle = Bundle.main) {
    self.appDict = appBundle.infoDictionary
    self.frameworkDict = Bundle(for: type(of: self)).infoDictionary
  }
  func asd() {
    
  }
  
  public func userAgentHeader() -> HttpHeader {
    let separator = "; "
    let appName = appDict?["CFBundleName"] as? String ?? "unknown"
    let appVersionName = appDict?["CFBundleShortVersionString"] as? String ?? "unknown"
    let appBuildCode = appDict?["CFBundleVersion"] as? String ?? "unknown"
    let osVersion = "\(Constants.platform) \(UIDevice.current.systemVersion)"
    let device = UIDevice.current.model
    let sdkName = frameworkDict?["CFBundleName"] as? String ?? "unknown"
    let sdkVersionName = frameworkDict?["CFBundleShortVersionString"] as? String ?? "unknown"
    let sdkBuildCode = frameworkDict?["CFBundleVersion"] as? String ?? "unknown"
    let userAgent = [appName, Constants.platform, appVersionName, appBuildCode, osVersion, device, sdkName, sdkVersionName, sdkBuildCode].joined(separator: separator)
    return HttpHeader.userAgent(userAgent)
  }
}


//struct HttpHeaders {
//
//  private var headers: [HttpHeader] = []
//
//  public init() {}
//
//  public init(_ headers: [HttpHeader]) {
//    self.init()
//
//    headers.forEach { update($0) }
//  }
//
////  public mutating func update(name: String, value: String) {
////    update(HttpHeader(name: name, value: value))
////  }
//
//  public mutating func update(_ header: HttpHeader) {
//    guard let index = headers.firstIndex(of: header) else {
//      headers.append(header)
//      return
//    }
//
//    headers.replaceSubrange(index...index, with: [header])
//  }
//}

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


extension RequestHelper {
  struct Constants {
    static let platform = "iOS"
    static let sdkName = "VerifySDK"
  }
}
