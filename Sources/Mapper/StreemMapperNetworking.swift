//
//  Alamofire+Mapper.swift
//  AlamofireMapper
//
//  Created by Emilien Stremsdoerfer on 2016-08-23.
//
//  The MIT License (MIT)
//
//  Copyright (c) 2016 Emilien Stremsdoerfer
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

import Foundation
import Mapper

extension Request {
    
    /**
     Handler to be called once the request has finished and parses the response into the desired object
     
     - parameter completionHandler:  The code to be executed once the request has finished and that will provide the parsed object
     - returns: The request.
     */
    @discardableResult
    public func responseObject<T: Mappable>(_ completionHandler:@escaping (Response<T>) -> Void) -> Self {
        return responseJSON { (response:Response<Any>) in
            let newResult = response.result.flatMap({ (value) -> Result<T> in
                if let responseObject:T = T.from(JSON:value) {
                    return .success(responseObject)
                } else {
                    return .failure(StreemNetworkingMapperError.deserialization(value))
                }
            })
            completionHandler(Response(response: response.response, data: response.data, result: newResult))
        }
    }
    
    /**
     Handler to be called once the request has finished and parses the response into an array of desired object
     
     - parameter completionHandler:  The code to be executed once the request has finished and that will provide the object array
     - returns: The request.
     */
    @discardableResult
    public func responseArray<T: Mappable>(rootKey:String? = nil, _ completionHandler:@escaping (Response<[T]>) -> Void) -> Self {
        return responseJSON { (response:Response<Any>) in
            let newResult = response.result.flatMap({ (value) -> Result<[T]> in
                if let responseObject:[T] = [T].from(JSON:value, rootKey: rootKey) {
                    return .success(responseObject)
                } else {
                    return .failure(StreemNetworkingMapperError.deserialization(value))
                }
            })
            completionHandler(Response(response: response.response, data: response.data, result: newResult))
        }
    }
}

enum StreemNetworkingMapperError: StreemError {
    var domain: String { get { return "com.justalab.JustaNetworkingMapper" } }
    var description:String {
        switch self {
            case .deserialization(let value): return "Could not deserialize object: \(value)"
        }
    }
    
    case deserialization(Any)
}
