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
 Future is a class at the disposal of other modules that wants to returns Future of specific objects.
 You can check module MapperFuture that handles the Mappable types managed by the Mapper library
 */
open class Future<T>{
    
    /**
    Variable to keep the state of the result in case closure is added after result arrived
    */
    private var result:Result<T>?
    
    /**
     Variable to keep the state of the progress in case closure is added after any progress arrived
    */
    private var progress:(Int64,Int64)?
    
    /**
     An instance closure that can be define with the matching function:
     func onComplete(_ handler:@escaping ((Result<T>) -> Void))
     */
    private var completionHandler:((Result<T>) -> Void)?
    
    /**
     An instance closure that can be define with the matching function:
     func onProgress(_ handler:@escaping((_ receivedSize:Int, _ expectedSize:Int) -> Void))
     */
    private var progressHandler:((_ receivedSize:Int64, _ expectedSize:Int64) -> Void)?
 
    
    /**
     When called this method will terminate the Future and call the completionHandler
     - parameter result: The result to pass to the completion handler
    */
    func fill(result:Result<T>){
        self.result = result
        completionHandler?(result)
    }
    
    /**
     When called, this method will simply call the progressHandler
     - parameter (receivedSize, expectedSize): Integers that allow us to define the progress
    */
    func fill(progress:(receivedSize:Int64,expectedSize:Int64)){
        self.progress = (progress.receivedSize, progress.expectedSize)
        progressHandler?(progress.receivedSize, progress.expectedSize)
    }
    
    /**
     Method that defines the completionHandler of the Future. If a result is already there, the handler will be called right away
     - parameter handler: The closure that takes a Result<T> in parameter
    */
    public func onComplete(_ handler:@escaping ((Result<T>) -> Void)){
        completionHandler = handler
        if let r = result { //If result was already filled we call the handler with the stored value
            handler(r)
        }
    }
    
    /**
     Method that defines the progressHandler. If a progress has already been received, the handler will be called right away with the latest progress info.
     - parameter handler: The closure that takes (receivedSize, expectedSize) in parameter
    */
    public func onProgress(_ handler:@escaping((_ receivedSize:Int64, _ expectedSize:Int64) -> Void)) {
        progressHandler = handler
        if let p = progress{
            handler(p.0, p.1)
        }
    }
    
    /**
     Map allows you to apply a function to a Future. Completion handler will be called once the Future is complete and after applying the funtion to the value if there's any.
     - parameter f: A function that takes the type of the first Future and returns a new type
     - returns: The new Future
    */
    func map<U>(_ f:@escaping ((T)->U)) -> Future<U> {
        let newFuture = Future<U>()
        self.completionHandler = {(value:Result<T>) in
            switch value {
            case .success(let value): newFuture.fill(result:.success(f(value)))
            case .failure(let err): newFuture.fill(result:.failure(err))
            }
        }
        self.progressHandler = {(receivedSize, expectedSize) in
            newFuture.fill(progress: (receivedSize, expectedSize))
        }
        return newFuture
    }
    
    /**
     Flatmap allows you to chain Futures. Completion handler will be called when both futures are completed. Progress handler will simply be called twice
     - parameter f: A function that returns a Future
     - returns: A new future
     */
    func flatMap<U>(_ f:@escaping ((T)->Future<U>)) -> Future<U> {
        let newFuture = Future<U>()
        self.onComplete { (result:Result<T>) in
            switch result {
            case .success(let value):
                let tmp = f(value)
                tmp.onComplete(newFuture.fill)
                tmp.onProgress(newFuture.fill)
            case .failure(let error):
                newFuture.fill(result:.failure(error))
            }
        }
        self.onProgress { (receivedSize, expectedSize) in
            newFuture.fill(progress: (receivedSize, expectedSize))
        }
        return newFuture
    }
}
