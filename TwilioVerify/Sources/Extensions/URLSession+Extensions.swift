//
//  URLSession+Extensions.swift
//  TwilioVerify
//
//  Created by Sergio Fierro on 6/2/20.
//  Copyright © 2020 Twilio. All rights reserved.
//

import Foundation

extension URLSession {
  func dataTask(with request: URLRequest, result: @escaping (Result<(HTTPURLResponse, Data), Error>) -> Void) -> URLSessionDataTask {
    return dataTask(with: request) { (data, response, error) in
      if let error = error {
        result(.failure(error))
        return
      }
      guard let data = data else {
        result(.failure(NetworkError.invalidData))
        return
      }
      guard let response = response as? HTTPURLResponse, response.statusCode < 300 else {
        result(.failure(NetworkError.invalidResponse))
        return
      }
      result(.success((response, data)))
    }
  }
}
