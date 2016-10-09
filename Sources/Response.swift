//
//  Response.swift
//  HerPlayground
//
//  Created by Emilien on 10/1/16.
//  Copyright © 2016 Emilien Stremsdoerfer. All rights reserved.
//

import Foundation

public class Response<Value>{
    open let response:HTTPURLResponse?
    open let data: Data
    open let result:Result<Value>
    
    init(response:HTTPURLResponse?, data:Data, result:Result<Value>){
        self.response = response
        self.data = data
        self.result = result
    }
}
