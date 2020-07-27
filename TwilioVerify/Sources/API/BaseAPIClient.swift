//
//  BaseAPIClient.swift
//  TwilioVerify
//
//  Created by Sergio Fierro on 7/27/20.
//  Copyright © 2020 Twilio. All rights reserved.
//

import Foundation

internal class BaseAPIClient {
  
  private let dateProvider: DateProvider
  
  init(dateProvider: DateProvider) {
    self.dateProvider = dateProvider
  }
  
  func validateFailureResponse(error: Error, retryBlock: (Int) -> (), retries: Int, failure: @escaping FailureBlock) {
    guard retries > 0, let networkError = error as? NetworkError,
      case .unsuccessStatusCode = networkError,
      networkError.failureResponse?.responseCode == Constants.unauthorized,
      let date = networkError.failureResponse?.headers[Constants.dateHeaderKey] as? String else {
      failure(error)
      return
    }
    syncTime(date: date)
    retryBlock(retries - 1)
  }
}

private extension BaseAPIClient {
  
  private func syncTime(date: String) {
    dateProvider.syncTime(date: date)
  }
}

extension BaseAPIClient {
  struct Constants {
    static let retryTimes = 1
    static let unauthorized = 401
    static let dateHeaderKey = "Date"
  }
}
