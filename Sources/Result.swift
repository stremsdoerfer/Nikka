//
//  Result.swift
//  HerPlayground
//
//  Created by Emilien on 10/5/16.
//  Copyright © 2016 Emilien Stremsdoerfer. All rights reserved.
//

import Foundation

/**
 Result is an enum that will be sent back with the response. It has two states: success and failure. If success, it will contain the desired value, if failure, it will have an StreemError
 */
public enum Result<Value> {
    case success(Value)
    case failure(StreemError)
    
    /**
     Computed variable that will return the value if the result is a success and nil otherwise
    */
    public var value: Value? {
        switch self {
        case .success(let value):
            return value
        case .failure:
            return nil
        }
    }
    
    /**
     Computed variable that will return the error if the result is a failure and nil otherwise
     */
    public var error: StreemError? {
        switch self {
        case .success:
            return nil
        case .failure(let error):
            return error
        }
    }
    
    /**
     Map function, that will allow you to apply a function to a value is the result is a success.
    */
    public func map<U>(_ f:((Value) -> U)) -> Result<U> {
        switch self {
        case .success(let value):
            return .success(f(value))
        case .failure(let error):
            return .failure(error)
        }
    }
    
    /**
     FlatMap function, this allows you to chain different results
    */
    public func flatMap<U>(_ f:((Value)->Result<U>)) -> Result<U> {
        switch self {
        case .success(let value):
            return f(value)
        case .failure(let error):
            return .failure(error)
        }
    }
}
