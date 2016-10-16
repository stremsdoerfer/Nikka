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

open class Future<T>{
    
    var result:Result<T>?
    private var completionHandler:((Result<T>) -> Void)?
 
    
    func fill(_ result:Result<T>){
        self.result = result
        completionHandler?(result)
    }
    
    func onComplete(_ handler:@escaping ((Result<T>) -> Void)){
        completionHandler = handler
        if let r = result { //If result was already filled we call the handler with the stored value
            handler(r)
        }
    }
    
    func map<U>(_ f:@escaping ((T)->U)) -> Future<U> {
        let newFuture = Future<U>()
        self.completionHandler = {(value:Result<T>) in
            switch value {
                case .success(let value): newFuture.fill(.success(f(value)))
                case .failure(let err): newFuture.fill(.failure(err))
            }
        }
        return newFuture
    }
    
    func flatMap<U>(_ f:@escaping ((T)->Future<U>)) -> Future<U> {
        let newFuture = Future<U>()
        self.onComplete { (result:Result<T>) in
            switch result {
                case .success(let value): f(value).onComplete(newFuture.fill)
                case .failure(let error): newFuture.fill(.failure(error))
            }
        }
        return newFuture
    }
}


/*
 User log in -> Future<User>
 Get User pic -> Future<Picture>
 
 onSuccess = { (pic) in
 
 }
 
 */
