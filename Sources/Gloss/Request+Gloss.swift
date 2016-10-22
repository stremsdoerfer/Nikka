//
//  Response+Gloss.swift
//  StreemNetworking
//
//  Created by Emilien on 10/21/16.
//  Copyright © 2016 Emilien Stremsdoerfer. All rights reserved.
//

import Foundation
import Gloss

extension Request {
    
    /**
     Handler to be called once the request has finished and parses the response into the desired object
     
     - parameter completionHandler:  The code to be executed once the request has finished and that will provide the parsed object
     - returns: The request.
     */
    @discardableResult
    public func responseObject<T: Decodable>(_ completionHandler:@escaping (Response<T>) -> Void) -> Self {
        return responseJSON { (response:Response<Any>) in
            let newResult = response.result.flatMap({ (value) -> Result<T> in
                if let jsonDict = value as? [String:Any], let responseObject = T(json:jsonDict){
                    return .success(responseObject)
                } else {
                    return .failure(StreemNetworkingError.jsonMapping(value))
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
    public func responseArray<T: Decodable>(_ completionHandler:@escaping (Response<[T]>) -> Void) -> Self {
        return responseJSON { (response:Response<Any>) in
            let newResult = response.result.flatMap({ (value) -> Result<[T]> in
                if let jsonArray = value as? [[String:Any]], let responseObject:[T] = [T].from(jsonArray:jsonArray) {
                    return .success(responseObject)
                } else {
                    return .failure(StreemNetworkingError.jsonMapping(value))
                }
            })
            completionHandler(Response(response: response.response, data: response.data, result: newResult))
        }
    }
}
