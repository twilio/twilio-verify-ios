//
//  BaseAPIClient.swift
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

class BaseAPIClient {
  
  private let dateProvider: DateProvider
  
  init(dateProvider: DateProvider) {
    self.dateProvider = dateProvider
  }
  
  func validateFailureResponse(withError error: Error, retries: Int, retryBlock: (Int) -> (), failure: @escaping FailureBlock) {
    guard retries > 0, let networkError = error as? NetworkError,
      case .failureStatusCode = networkError,
      networkError.failureResponse?.statusCode == Constants.unauthorized,
      let date = networkError.failureResponse?.headers.first(where: { ($0.key as? String)?.compare(Constants.dateHeaderKey, options: .caseInsensitive) == .orderedSame })?.value as? String else {
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
