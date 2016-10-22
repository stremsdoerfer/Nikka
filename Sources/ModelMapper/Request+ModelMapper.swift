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
                if let jsonDict = value as? NSDictionary, let responseObject:T = T.from(jsonDict) {
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
    public func responseArray<T: Mappable>(_ completionHandler:@escaping (Response<[T]>) -> Void) -> Self {
        return responseJSON { (response:Response<Any>) in
            let newResult = response.result.flatMap({ (value) -> Result<[T]> in
                if let jsonArray = value as? NSArray, let responseObject:[T] = T.from(jsonArray) {
                    return .success(responseObject)
                } else {
                    return .failure(StreemNetworkingError.jsonMapping(value))
                }
            })
            completionHandler(Response(response: response.response, data: response.data, result: newResult))
        }
    }
}
