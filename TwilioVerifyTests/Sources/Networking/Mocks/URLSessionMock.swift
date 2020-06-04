//
//  URLSessionMock.swift
//  TwilioVerifyTests
//
//  Created by Sergio Fierro on 6/2/20.
//  Copyright © 2020 Twilio. All rights reserved.
//

import XCTest

class URLSessionMock: URLSession {
  
  private let urlSessionDataTask: URLSessionDataTaskMock
  
  init(data: Data?, httpURLResponse: HTTPURLResponse?, error: Error?) {
    urlSessionDataTask = URLSessionDataTaskMock(data: data, httpURLResponse: httpURLResponse, requestError: error)
  }
  
  override func dataTask(with request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
    urlSessionDataTask.completionHandler = completionHandler
    return urlSessionDataTask
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
