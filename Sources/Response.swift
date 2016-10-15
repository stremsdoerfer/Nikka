//
//  Response.swift
//  HerPlayground
//
//  Created by Emilien on 10/1/16.
//  Copyright © 2016 Emilien Stremsdoerfer. All rights reserved.
//

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
