//
//  JustaNetworking+Future.swift
//  HerPlayground
//
//  Created by Emilien on 10/5/16.
//  Copyright © 2016 Emilien Stremsdoerfer. All rights reserved.
//

import Foundation
import Mapper

extension Request{
    
    public func response<T: Mappable>() -> Future<T> {
        let future = Future<T>()
        self.progress({ (receivedSize, expectedSize) in
            
        }).response { (response:Response<T>) in
            future.fill(response.result)
        }
        return future
    }
    
    public func response<T: Mappable>() -> Future<[T]> {
        let future = Future<[T]>()
        self.progress({ (receivedSize, expectedSize) in
            
        }).response { (response:Response<[T]>) in
            future.fill(response.result)
        }
        return future
    }
    
}