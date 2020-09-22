//
//  BaseAPIClient.swift
//  TwilioVerify
//
//  Created by Sergio Fierro on 7/28/20.
//  Copyright © 2020 Twilio. All rights reserved.
//

import Foundation

class BaseAPIClient {
  
  private let dateProvider: DateProvider
  
  init(dateProvider: DateProvider) {
    self.dateProvider = dateProvider
  }
  
  func validateFailureResponse(withError error: Error, retries: Int, retryBlock: (Int) -> (), failure: @escaping FailureBlock) {
    guard retries > 0, let networkError = error as? NetworkError,
      case .failureStatusCode = networkError,
      networkError.failureResponse?.responseCode == Constants.unauthorized,
      let date = networkError.failureResponse?.headers[Constants.dateHeaderKey] as? String else {
        failure(error)
        return
    }
    syncTime(date)
    retryBlock(retries - 1)
  }
}

private extension BaseAPIClient {
  func syncTime(_ date: String) {
    dateProvider.syncTime(date)
  }
}

extension BaseAPIClient {
  struct Constants {
    static let retryTimes = 1
    static let unauthorized = 401
    static let notFound = 404
    static let dateHeaderKey = "Date"
  }
}
