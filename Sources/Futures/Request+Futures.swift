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
 Request extension that allows you to get Future out of a standard and a JSON response
 */
public extension Request {

    /**
     Method that creates a Future from the basic response
     - returns: Future<(HTTPURLResponse,Data)> The created future
     */
    public func response() -> Future<(HTTPURLResponse, Data)> {
        let future = Future<(HTTPURLResponse, Data)>()

        self.downloadProgress({ (receivedSize, expectedSize) in
            future.fill(downloadProgress: (receivedSize, expectedSize))
        }).uploadProgress({ (bytesSent, totalBytes) in
            future.fill(uploadProgress: (bytesSent, totalBytes))
        }).response { (response: HTTPURLResponse?, data: Data, error: StreemError?) in
            if let response = response {
                future.fill(result: .success(response, data))
            } else if let error = error {
                future.fill(result: .failure(error))
            } else {
                future.fill(result: .failure(StreemNetworkingError.unknown("Response and error are nil")))
            }
        }

        return future
    }

    /**
     Method that creates an Future from the json response
     - returns: Future<Any> The created future
     */
    public func responseJSON() -> Future<Any> {
        let future = Future<Any>()
        self.downloadProgress({ (receivedSize, expectedSize) in
            future.fill(downloadProgress: (receivedSize, expectedSize))
        }).uploadProgress({ (bytesSent, totalBytes) in
            future.fill(uploadProgress: (bytesSent, totalBytes))
        }).responseJSON { (response: Response<Any>) in
            future.fill(result: response.result)
        }
        return future
    }

}
