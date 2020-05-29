//
//  Request.swift
//  TwilioVerify
//
//  Created by Sergio Fierro on 5/29/20.
//  Copyright © 2020 Twilio. All rights reserved.
//

import Foundation

class URLRequestBuilder {
  private var requestHelper: RequestHelper
  private var urlRequest: URLRequest
  private var httpMethod: HTTPMethod = .get
  private var parameters: Parameters = Parameters()
  private var headers: HTTPHeaders = HTTPHeaders()
  
  required init(requestHelper: RequestHelper, url: String) throws {
    self.requestHelper = requestHelper
    guard let url = URL(string: url) else {
      throw NetworkError.invalidURL
    }
    urlRequest = URLRequest(url: url)
  }
  
  func httpMethod(_ method: HTTPMethod) -> URLRequestBuilder {
    self.httpMethod = method
    return self
  }
  
  func parameters(_ parameters: [Parameter]) -> URLRequestBuilder {
    self.parameters.addAll(parameters)
    return self
  }
  
  func headers(_ headers: [HTTPHeader]) -> URLRequestBuilder {
    self.headers.addAll(headers)
    return self
  }
  
  func build() throws -> URLRequest {
    headers.addAll(requestHelper.commonHeaders(httpMethod: httpMethod))
    urlRequest.httpMethod = httpMethod.value
    urlRequest.allHTTPHeaderFields = headers.dictionary
    switch httpMethod {
      case .post, .put, .delete:
        do {
          urlRequest.httpBody = try transformParameters()
        } catch {
          throw(error)
        }
      case .get:
        guard let request = urlRequest.url?.absoluteString.appending(addQueryParameters()) else {
          return urlRequest
        }
        urlRequest.url = URL(string: request)
    }
    return urlRequest
  }
}

private extension URLRequestBuilder {
  
  struct Constants {
    static let queryPrefix = "?"
  }
  
  func transformParameters() throws -> Data? {
    do {
      if let headers = urlRequest.allHTTPHeaderFields, headers.contains(where: { $0.key == HTTPHeader.Constant.contentType && $0.value == MediaType.urlEncoded.value }) {
        return  try parameters.asString().data(using: .utf8)
      } else {
        return try parameters.asData()
      }
    } catch {
      throw(error)
    }
  }
  
  func addQueryParameters() -> String {
    guard let parameters = try? parameters.asString() else {
      return String()
    }
    
    return Constants.queryPrefix.appending(parameters)
  }
}

extension CharacterSet {
  static let customURLQueryAllowed: CharacterSet = {
    let forbiddenCharacters = CharacterSet(charactersIn: "+")
    return CharacterSet.urlQueryAllowed.subtracting(forbiddenCharacters)
  }()
}
