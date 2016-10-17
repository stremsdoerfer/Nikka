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

public protocol StreemError: Error, CustomStringConvertible{}

/**
 StreemNetworkingError is the StreemNetworking implementation of Error Type. It provides all the errors that can be thrown by the StreemNetworking Library and a way to compare them
 */
public enum StreemNetworkingError: StreemError, Equatable {
    
    /**
     Error thrown when the encoding of the parameters fails when creating a request.
    */
    case parameterEncoding(Any)
    
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
     Unkown error has been thrown
    */
    case unknown(String)

    
    public var description:String {
        switch self {
            case .parameterEncoding(let value): return "An error occurred while encoding parameter: \(value)"
            case .jsonDeserialization: return "Could not parse data to JSON."
            case .http(let code): return "HTTP Error occured with code:\(code)"
            case .emptyResponse: return "Tried to deserialize response, but no data was found"
            case .invalidURL(let url): return "Provided URL is not valid: \(url)"
            case .nonHTTPResponse: return "Response was not an HTTP response, aborting."
            case .unknown(let description): return description
        }
    }
    
    /**
     Convenience method that will transform an Error thown in the process to A StreemNetworkingError
    */
    static func error(with error:Error) -> StreemNetworkingError{
        return StreemNetworkingError.unknown(error.localizedDescription)
    }
    
    /**
     Convenience method that creates a http error with a given code
    */
    static func error(with httpCode:Int) -> StreemNetworkingError{
        return .http(httpCode)
    }
    
    /**
     Comparison method that returns a boolean whether or not two errors are matching.
    */
    func isEqual(err: StreemNetworkingError)->Bool {
        switch self {
        case .parameterEncoding(_):
            if case .parameterEncoding = err { return true }
        case .emptyResponse:
            if case .emptyResponse = err { return true }
        case .http(let codeA):
            if case .http(let codeB) = err { return codeA == codeB}
        case .unknown(_):
            if case .unknown = err { return true }
        case .jsonDeserialization:
            if case .jsonDeserialization = err { return true }
        case .invalidURL(_):
            if case .invalidURL = err { return true }
        case .nonHTTPResponse:
            if case .nonHTTPResponse = err { return true }
        }
        return false
    }
}

/**
 Equatable implementation
 */
public func ==(lhs: StreemNetworkingError, rhs: StreemNetworkingError)->Bool {
    return lhs.isEqual(err: rhs)
}
