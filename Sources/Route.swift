//
//  Route.swift
//  HerPlayground
//
//  Created by Emilien on 10/4/16.
//  Copyright © 2016 Emilien Stremsdoerfer. All rights reserved.
//

import Foundation

public struct Route{
    let headers:[String:String]?
    let method:HTTPMethod
    let path:String
    let params:[String:Any]?
    let encoding:ParameterEncoding
    
    public init(path:String, method:HTTPMethod = .get, params:[String:Any]? = nil, headers:[String:String]? = nil, encoding:ParameterEncoding? = nil){
        self.method = method
        self.path = path
        self.params = params
        self.headers = headers
        self.encoding = encoding ?? ParameterEncoding.defaultEncodingForMethod(method)
    }
}
