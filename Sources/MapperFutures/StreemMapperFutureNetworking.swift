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

public extension Request{
    
    public func response<T: Mappable>() -> Future<T> {
        let future = Future<T>()
        self.progress({ (receivedSize, expectedSize) in
            
        }).responseObject { (response:Response<T>) in
            future.fill(response.result)
        }
        return future
    }
    
    public func response<T: Mappable>(rootKey:String? = nil) -> Future<[T]> {
        let future = Future<[T]>()
        self.progress({ (receivedSize, expectedSize) in
            
        }).responseArray(rootKey:rootKey) { (response:Response<[T]>) in
            future.fill(response.result)
        }
        return future
    }
    
}
