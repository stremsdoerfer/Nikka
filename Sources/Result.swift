//
//  Result.swift
//  HerPlayground
//
//  Created by Emilien on 10/5/16.
//  Copyright © 2016 Emilien Stremsdoerfer. All rights reserved.
//

import Foundation

public enum Result<Value> {
    case success(Value)
    case failure(StreemError)
    
    public var value: Value? {
        switch self {
        case .success(let value):
            return value
        case .failure:
            return nil
        }
    }
    
    public var error: StreemError? {
        switch self {
        case .success:
            return nil
        case .failure(let error):
            return error
        }
    }
    
    public func map<U>(_ f:((Value) -> U)) -> Result<U> {
        switch self {
        case .success(let value):
            return .success(f(value))
        case .failure(let error):
            return .failure(error)
        }
    }
    
    public func flatMap<U>(_ f:((Value)->Result<U>)) -> Result<U> {
        switch self {
        case .success(let value):
            return f(value)
        case .failure(let error):
            return .failure(error)
        }
    }
}
