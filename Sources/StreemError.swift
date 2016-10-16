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

public protocol StreemError : Error{
    var domain:String { get }
    var description:String { get }
}

public enum StreemNetworkingError: StreemError {
    public var domain: String { get { return "com.justalab.JustaNetworking" } }
    public var description:String {
        switch self {
            case .parameterEncoding(let value): return "An error occurred while encoding parameter: \(value)"
            case .jsonDeserialization: return "Could not parse data to JSON."
            case .http(let code): return "HTTP Error occured with code:\(code)"
            case .emptyResponse: return "Tried to deserialize response, but no data was found"
            case .unknown(let description): return description
        }
    }
    
    case parameterEncoding(Any), jsonDeserialization, emptyResponse, http(Int) ,unknown(String)
    
    static func errorWith(error:Error) -> StreemNetworkingError{
        return StreemNetworkingError.unknown(error.localizedDescription)
    }
    
    static func errorWith(httpCode:Int) -> StreemNetworkingError{
        return .http(httpCode)
    }
}

public func ==(lhs: StreemNetworkingError, rhs: StreemNetworkingError) -> Bool {
    switch (lhs, rhs) {
    case (.jsonDeserialization, .jsonDeserialization) : return true
    case (.http(let codeA), .http(let codeB)) : return codeA == codeB
    case (.unknown(_), .unknown(_)): return true
    case (.parameterEncoding(_), .parameterEncoding(_)): return true
    case (.emptyResponse, .emptyResponse): return true
    default: return false
    }
}
