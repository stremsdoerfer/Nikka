/* This software is licensed under the Apache 2 license, quoted below.

 Copyright 2016 Emilien Stremsdoerfer <emstre@gmail.com>
 Licensed under the Apache License, Version 2.0 (the "License"); you may not
 use this file except in compliance with the License. You may obtain a copy of
 the License at

 http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
 WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
 License for the specific language governing permissions and limitations under
 the License.
 */

import Foundation

/**
 HTTP method definitions.
 See https://tools.ietf.org/html/rfc7231#section-4.3
 */
public enum HTTPMethod: String {
    case options, get, head, post, put, patch, delete, trace, connect
}

/**
 ParameterEncoding is an Enum that defines how the parameters will be encoded in the request
 */
public enum ParameterEncoding {

    /**
     url encoding will append the parameter in the url as query parameters.
     For instance if parameters are ["foo":"bar","test":123] url will look something like https://my-website.com/api/path?foo=bar&test=123
    */
    case url

    /**
     json encoding will serialize the parameters in JSON and put them in the body of the request
    */
    case json

    /**
     form encoding will url encode the parameters and put them in the body of the request
    */
    case form
}

/**
 URLRequest extension that allows us to encode the parameters directly in the request
 */
extension URLRequest {

    /**
     Mutating function that, with a given set of parameters, will take care of building the request
     It is a mutating function and has side effects, it will modify the headers, the body and the url of the request.
     Make sure that this function not called after setting one of the above, or they might be overriden.
     - parameter parameters: A dictionary that needs to be encoded
     - parameter encoding: The encoding in which the parameters should be encoded
    */
    mutating func encode(parameters: [String: Any]?, encoding: ParameterEncoding) throws {
        guard let parameters = parameters else {return}

        switch encoding {
        case .url:
            guard let url = self.url else {return}
            var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false)
            if urlComponents != nil && !parameters.isEmpty {
                let paramString = (parameters.map { "\($0)=\($1)" } as [String]).joined(separator: "&")
                let percentEncodedQuery = (urlComponents!.percentEncodedQuery.map { $0 + "&" } ?? "") + paramString
                urlComponents!.percentEncodedQuery = percentEncodedQuery
                self.url = urlComponents!.url
            }
        case .json:
            do {
                let data = try JSONSerialization.data(withJSONObject: parameters, options: [])
                self.httpBody = data
                self.setValue("application/json", forHTTPHeaderField: "Content-Type")
            } catch {
                throw NikkaNetworkingError.parameterEncoding(parameters)
            }
        case .form:
            let paramString = (parameters.map { "\($0)=\($1)" } as [String]).joined(separator: "&")
            self.httpBody = paramString.data(using: String.Encoding.utf8, allowLossyConversion: false)
            self.setValue("application/x-www-form-urlencoded; charset=utf-8", forHTTPHeaderField: "Content-Type")
        }
    }

    mutating func encode(form: MultipartForm) throws {
        self.httpBody = try form.encode()
        self.setValue("multipart/form-data; boundary=\(form.boundary)", forHTTPHeaderField: "Content-Type")
    }
}
