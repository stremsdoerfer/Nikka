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
import ObjectMapper

/**
 Request extension that allows you to get Future of Mappable Types
 */
public extension Request {

    /**
     Method that creates an Future from the response
     - returns: Future<T> The created future
     */
    public func responseObject<T: Mappable>() -> Future<T> {
        let future = Future<T>()
        self.downloadProgress({ (receivedSize, expectedSize) in
            future.fill(downloadProgress: (receivedSize, expectedSize))
        }).uploadProgress({ (bytesSent, totalBytes) in
            future.fill(uploadProgress: (bytesSent, totalBytes))
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
    public func responseArray<T: Mappable>() -> Future<[T]> {
        let future = Future<[T]>()
        self.downloadProgress({ (receivedSize, expectedSize) in
            future.fill(downloadProgress: (receivedSize, expectedSize))
        }).uploadProgress({ (bytesSent, totalBytes) in
            future.fill(uploadProgress: (bytesSent, totalBytes))
        }).responseArray { (response: Response<[T]>) in
            future.fill(result:response.result)
        }
        return future
    }

}
