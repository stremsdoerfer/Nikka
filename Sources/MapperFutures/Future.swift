//
//  Future.swift
//  HerPlayground
//
//  Created by Emilien on 10/2/16.
//  Copyright © 2016 Emilien Stremsdoerfer. All rights reserved.
//

import Foundation

open class Future<T>{
    
    var result:Result<T>?
    fileprivate var completionHandler:((Result<T>) -> Void)?
 
    
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
