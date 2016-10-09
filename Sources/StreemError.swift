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

enum StreemNetworkingError: StreemError {
    var domain: String { get { return "com.justalab.JustaNetworking" } }
    var description:String {
        switch self {
            case .parameterEncoding(let value): return "An error occurred while encoding parameter: \(value)"
        }
    }
    
    case parameterEncoding(Any)
}
