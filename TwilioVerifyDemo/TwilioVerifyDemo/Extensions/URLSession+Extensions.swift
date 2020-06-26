//
//  URLSession+Extensions.swift
//  TwilioVerifyDemo
//
//  Created by Santiago Avila on 6/25/20.
//  Copyright © 2020 Twilio. All rights reserved.
//

import Foundation

extension URLSession {
  func dataTask(with request: URLRequest, result: @escaping (Result<(URLResponse, Data), Error>) -> Void) -> URLSessionDataTask {
    return dataTask(with: request) { (data, response, error) in
      if let error = error {
        result(.failure(error))
        return
      }
      guard let response = response else {
        result(.failure(NetworkError.invalidResponse))
        return
      }
      guard let data = data else {
        result(.failure(NetworkError.invalidData))
        return
      }
      result(.success((response, data)))
    }
  }
}
