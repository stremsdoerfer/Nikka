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
 A Route is a struct that allows us to define a request
 */
public struct Route {

    /**
     The HTTP headers to be sent with the request
    */
    let headers: [String: String]?

    /**
     The HTTP Method to send the request as
    */
    let method: HTTPMethod

    /**
     The relative path of the request
    */
    let path: String

    /**
     The parameters to be sent with the request
    */
    let params: [String: Any]?

    /**
     The encoding to use for the parameters. Default is json for HTTPMethod .post and .put, and .url for the others
    */
    let encoding: ParameterEncoding?

    /**
     */
    let multipartForm: MultipartForm?

    /**
     Initializer of the Route, path is the only non optional parameter.
     For instance: Route(path:"/user") will result is a get request without any parameters or headers
    */
    public init(path: String,
                method: HTTPMethod = .get,
                params: [String: Any]? = nil,
                headers: [String: String]? = nil,
                encoding: ParameterEncoding? = nil,
                multipartForm: MultipartForm? = nil) {
        self.method = method
        self.path = path
        self.params = params
        self.headers = headers
        self.encoding = encoding
        self.multipartForm = multipartForm
    }
}
