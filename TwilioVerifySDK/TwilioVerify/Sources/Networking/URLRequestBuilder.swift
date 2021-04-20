//
//  URLRequestBuilder.swift
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

class URLRequestBuilder {
  
  private var httpMethod: HTTPMethod
  private var parameters: [Parameter]
  private var headers: [HTTPHeader]
  private var url: String
  private var requestHelper: RequestHelper
  
  init(withURL url: String, requestHelper: RequestHelper) throws {
    self.url = url
    self.requestHelper = requestHelper
    httpMethod = .get
    parameters = []
    headers = []
  }
  
  func setHTTPMethod(_ method: HTTPMethod) -> URLRequestBuilder {
    httpMethod = method
    return self
  }
  
  func setParameters(_ parameters: [Parameter]) -> URLRequestBuilder {
    self.parameters.append(contentsOf: parameters)
    return self
  }
  
  func setHeaders(_ headers: [HTTPHeader]) -> URLRequestBuilder {
    self.headers.append(contentsOf: headers)
    return self
  }
  
  func build() throws -> URLRequest {
    guard let encodedUrl = url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
      let url = URL(string: encodedUrl) else {
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
          Logger.shared.log(withLevel: .error, message: error.localizedDescription)
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
        return params.asString().data(using: .utf8)
      } else {
        return try params.asData()
      }
    } catch {
      Logger.shared.log(withLevel: .error, message: error.localizedDescription)
      throw error
    }
  }
  
  func addQueryParameters(params: Parameters) -> String {
    let parameters = params.asString()
    guard !parameters.isEmpty else {
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
