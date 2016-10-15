//
//  Route.swift
//  HerPlayground
//
//  Created by Emilien on 10/4/16.
//  Copyright © 2016 Emilien Stremsdoerfer. All rights reserved.
//

import Foundation

/**
 A Route is a struct that allows us to define a request
 */
public struct Route{
    
    /**
     The HTTP headers to be sent with the request
    */
    let headers:[String:String]?
    
    /**
     The HTTP Method to send the request as
    */
    let method:HTTPMethod
    
    /**
     The relative path of the request
    */
    let path:String
    
    /**
     The parameters to be sent with the request
    */
    let params:[String:Any]?
    
    /**
     The encoding to use for the parameters. Default is json for HTTPMethod .post and .put, and .url for the others
    */
    let encoding:ParameterEncoding
    
    /**
     Initializer of the Route, path is the only non optional parameter.
     For instance: Route(path:"/user") will result is a get request without any parameters or headers
    */
    public init(path:String, method:HTTPMethod = .get, params:[String:Any]? = nil, headers:[String:String]? = nil, encoding:ParameterEncoding? = nil){
        self.method = method
        self.path = path
        self.params = params
        self.headers = headers
        self.encoding = encoding ?? ParameterEncoding.defaultEncodingForMethod(method)
    }
}
