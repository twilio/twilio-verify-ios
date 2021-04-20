//
//  URLSessionMock.swift
//  TwilioVerifyTests
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

import XCTest

class URLSessionMock: URLSession {
  
  private let urlSessionDataTask: URLSessionDataTaskMock?
  var urlSessionDataTasks: [URLSessionDataTaskMock]?
  private(set) var callsToDataTask = -1
  
  init(data: Data?, httpURLResponse: HTTPURLResponse?, error: Error?) {
    urlSessionDataTask = URLSessionDataTaskMock(data: data, httpURLResponse: httpURLResponse, requestError: error)
  }
  
  init(urlSessionDataTasks: [URLSessionDataTaskMock]) {
    self.urlSessionDataTasks = urlSessionDataTasks
    urlSessionDataTask = nil
  }
  
  override func dataTask(with request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
    if let urlSessionDataTask = urlSessionDataTask {
      urlSessionDataTask.completionHandler = completionHandler
      return urlSessionDataTask
    }
    if let urlSessionDataTasks = urlSessionDataTasks {
      callsToDataTask += 1
      urlSessionDataTasks[callsToDataTask].completionHandler = completionHandler
      return urlSessionDataTasks[callsToDataTask]
    }
    fatalError("Expected params not set")
  }
}

class URLSessionDataTaskMock: URLSessionDataTask {

  private let data: Data?
  private let httpURLResponse: HTTPURLResponse?
  private let requestError: Error?
  var completionHandler: ((Data?, URLResponse?, Error?) -> Void)?
  
  init(data: Data?, httpURLResponse: HTTPURLResponse?, requestError: Error?) {
    self.data = data
    self.httpURLResponse = httpURLResponse
    self.requestError = requestError
  }

  override func resume() {
    completionHandler?(data, httpURLResponse, requestError)
  }
}
