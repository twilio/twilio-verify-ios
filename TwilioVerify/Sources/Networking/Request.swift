//
//  Request.swift
//  TwilioVerify
//
//  Created by Sergio Fierro on 5/29/20.
//  Copyright © 2020 Twilio. All rights reserved.
//

import Foundation

class URLRequestBuilder {
  
  private var httpMethod: HTTPMethod = .get
  private var parameters: [Parameter] = []
  private var headers: [HTTPHeader] = []
    
  func httpMethod(_ method: HTTPMethod) -> URLRequestBuilder {
    self.httpMethod = method
    return self
  }
  
  func parameters(_ parameters: [Parameter]) -> URLRequestBuilder {
    self.parameters.append(contentsOf: parameters)
    return self
  }
  
  func headers(_ headers: [HTTPHeader]) -> URLRequestBuilder {
    self.headers.append(contentsOf: headers)
    return self
  }
  
  func build(requestHelper: RequestHelper, url: String) throws -> URLRequest {
    guard let url = URL(string: url) else {
      throw NetworkError.invalidURL
    }
    var urlRequest = URLRequest(url: url)
    urlRequest.httpMethod = httpMethod.value
    var httpHeaders = HTTPHeaders()
    httpHeaders.addAll(requestHelper.commonHeaders(httpMethod: httpMethod) + headers)
    urlRequest.allHTTPHeaderFields = httpHeaders.dictionary
    var params = Parameters()
    params.addAll(parameters)
    switch httpMethod {
      case .post, .put, .delete:
        do {
          urlRequest.httpBody = try transformParameters(httpHeaders: urlRequest.allHTTPHeaderFields, params: params)
        } catch {
          throw(error)
        }
      case .get:
        guard let request = urlRequest.url?.absoluteString.appending(addQueryParameters(params: params)) else {
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
  
  func transformParameters(httpHeaders: [String: String]?, params: Parameters) throws -> Data? {
    do {
      if let headers = httpHeaders, headers.contains(where: { $0.key == HTTPHeader.Constant.contentType && $0.value == MediaType.urlEncoded.value }) {
        return params.asString()?.data(using: .utf8)
      } else {
        return try params.asData()
      }
    } catch {
      throw(error)
    }
  }
  
  func addQueryParameters(params: Parameters) -> String {
    guard let parameters = params.asString(), !parameters.isEmpty else {
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
