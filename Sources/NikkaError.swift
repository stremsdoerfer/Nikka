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
 NikkaError protocol, all the errors related to Nikka should conform to that protocol
 */
public protocol NikkaError: Error, CustomStringConvertible {

    /**
     Method that will allow us to compare two errors
    */
    func isEqual(err: NikkaError) -> Bool
}

/**
 NikkaError extension that compares two NikkaError that conforms to Equatable
 */
public extension NikkaError where Self: Equatable {
    public func isEqual(err: NikkaError) -> Bool {
        if let err = err as? Self {return self == err}
        return false
    }
}

/**
 NikkaNetworkingError is the Nikka implementation of Error Type.
 It provides all the errors that can be thrown by the Nikka Library and a way to compare them
 */
public enum NikkaNetworkingError: NikkaError, Equatable {

    /**
     Error thrown when the encoding of the parameters fails when creating a request.
    */
    case parameterEncoding(Any)

    /**
     Error thrown when parameter could not be converted into data
    */
    case multipartEncoding(Any)

    /**
     Error thrown when the json deserialization fails. (when JSONSerialization.jsonObject throws)
    */
    case jsonDeserialization

    /**
     Error thrown when we try to parse the content of the response as JSON, but the response is actually empty
    */
    case emptyResponse

    /**
     Error thrown with a given HTTP status code. Default is thrown for code > 399
    */
    case http(Int)

    /**
     Error thrown when the url provided for the request cannot be parsed into a URL
     */
    case invalidURL(String)

    /**
     Error thrown when the response is not a HTTPResponse
    */
    case nonHTTPResponse

    /**
     Error thrown when the json mapping could not be done (Usually thrown by JSON Mapping libraries such as Argo or ObjectMapper)
     */
    case jsonMapping(Any)

    /**
     Unkown error has been thrown
    */
    case unknown(String)

    public var description: String {
        switch self {
        case .parameterEncoding(let value):
            return "An error occurred while encoding parameter: \(value)"
        case .multipartEncoding(let value):
            return "An error occurred while creating multipart data: \(value)"
        case .jsonDeserialization:
            return "Could not parse data to JSON."
        case .http(let code):
            return "HTTP Error occured with code:\(code)"
        case .emptyResponse:
            return "Tried to deserialize response, but no data was found"
        case .invalidURL(let url):
            return "Provided URL is not valid: \(url)"
        case .nonHTTPResponse:
            return "Response was not an HTTP response, aborting."
        case .jsonMapping(let object):
            return "Could not map json object to object, json:\(object)"
        case .unknown(let description):
            return description
        }
    }

    /**
     Convenience method that will transform an Error thown in the process to A NikkaNetworkingError
    */
    static func error(with error: Error) -> NikkaNetworkingError {
        return NikkaNetworkingError.unknown(error.localizedDescription)
    }

    /**
     Convenience method that creates a http error with a given code
    */
    static func error(with httpCode: Int) -> NikkaNetworkingError {
        return .http(httpCode)
    }

    /**
     Equatable implementation
     */
    //swiftlint:disable:next cyclomatic_complexity
    public static func == (lhs: NikkaNetworkingError, rhs: NikkaNetworkingError) -> Bool {
        switch lhs {
        case .parameterEncoding:
            if case .parameterEncoding = rhs { return true }
        case .multipartEncoding:
            if case .multipartEncoding = rhs { return true }
        case .emptyResponse:
            if case .emptyResponse = rhs { return true }
        case .http(let codeA):
            if case .http(let codeB) = rhs { return codeA == codeB}
        case .unknown:
            if case .unknown = rhs { return true }
        case .jsonDeserialization:
            if case .jsonDeserialization = rhs { return true }
        case .invalidURL:
            if case .invalidURL = rhs { return true }
        case .nonHTTPResponse:
            if case .nonHTTPResponse = rhs { return true }
        case .jsonMapping:
            if case .jsonMapping = rhs { return true }
        }
        return false
    }
}
