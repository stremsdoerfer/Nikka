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
 Result is an enum that will be sent back with the response.
 It has two states: success and failure.
 If success, it will contain the desired value, if failure, it will have an Error
 */
public enum Result<Value> {
    case success(Value)
    case failure(NikkaError)

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
    public var error: NikkaError? {
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
    public func map<U>(_ f: ((Value) -> U)) -> Result<U> {
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
    public func flatMap<U>(_ f: ((Value)->Result<U>)) -> Result<U> {
        switch self {
        case .success(let value):
            return f(value)
        case .failure(let error):
            return .failure(error)
        }
    }
}
