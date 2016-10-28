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
import Gloss

/**
 Request extension that allows you to get Future of Mappable Types
 */
public extension Request {

    /**
     Method that creates an Future from the response
     - returns: Future<T> The created future
     */
    public func responseObject<T: Decodable>() -> Future<T> {
        let future = Future<T>()
        self.progress({ (receivedSize, expectedSize) in
            future.fill(progress: (receivedSize, expectedSize))
        }).responseObject { (response: Response<T>) in
            future.fill(result:response.result)
        }
        return future
    }

    /**
     Method that creates an Future from the response
     - parameters rootKey: Optional, keypath of the array in the JSON
     - returns: Future<[T]> The created future
     */
    public func responseArray<T: Decodable>() -> Future<[T]> {
        let future = Future<[T]>()
        self.progress({ (receivedSize, expectedSize) in
            future.fill(progress: (receivedSize, expectedSize))
        }).responseArray { (response: Response<[T]>) in
            future.fill(result:response.result)
        }
        return future
    }

}
