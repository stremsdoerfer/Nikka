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
 The object returned by the request when it has completed.
 */
public class Response<Value>{
    
    /**
     The HTTPURL response returned by the session
    */
    open let response:HTTPURLResponse?
    
    /**
     The data contained in the response body, it will be empty if no data is returned
    */
    open let data: Data
    
    /**
     The result of the response that determine whether or not it was successful or not.
    */
    open let result:Result<Value>
    
    init(response:HTTPURLResponse?, data:Data, result:Result<Value>){
        self.response = response
        self.data = data
        self.result = result
    }
}
