//
//  StreemError.swift
//  HerPlayground
//
//  Created by Emilien on 10/1/16.
//  Copyright © 2016 Emilien Stremsdoerfer. All rights reserved.
//

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
            case .unknown(let description): return description
        }
    }
    
    case parameterEncoding(Any), jsonDeserialization, http(Int) ,unknown(String)
    
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
    default: return false
    }
}
