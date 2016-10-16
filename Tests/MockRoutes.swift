//
//  MockRoutes.swift
//  StreemNetworking
//
//  Created by Emilien on 10/15/16.
//  Copyright © 2016 Emilien Stremsdoerfer. All rights reserved.
//

@testable import StreemNetworking


//MARK:- httpbin.org routes
extension Route{
    static let ip         = Route(path:"/ip")
    static let get        = Route(path:"/get")
    static let postJSON   = {(params:[String:Any]) in Route(path:"/post", method:.post, params:params)}
    static let postForm   = {(params:[String:Any]) in Route(path:"/post", method:.post, params:params, encoding:.form)}
    static let getHeaders = {(headers:[String:String]) in Route(path:"/headers", headers:headers)}
    static let getParams  = {(params:[String:Any]) in Route(path:"/get", params:params)}
    static let delete     = Route(path:"/delete", method:.delete)
    static let putForm    = {(params:[String:Any]) in Route(path:"/put", method:.put, params:params, encoding:.form)}
    static let putJSON    = {(params:[String:Any]) in Route(path:"/put", method:.put, params:params)}
    
    static let getError   = {(code:Int) in Route(path:"/status/\(code)")}
    static let postError  = {(code:Int) in Route(path:"/status/\(code)", method:.post)}
    static let putError   = {(code:Int) in Route(path:"/status/\(code)", method:.put)}
    static let deleteError = {(code:Int) in Route(path:"/status/\(code)", method:.delete)}
}


//MARK:- deezer.com routes

extension Route{
    static let track    = {(id:Int64) in Route(path:"/track/\(id)")}
}

