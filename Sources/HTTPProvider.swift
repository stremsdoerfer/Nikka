//
//  HTTPProvider.swift
//  HerPlayground
//
//  Created by Emilien on 10/14/16.
//  Copyright © 2016 Emilien Stremsdoerfer. All rights reserved.
//

import Foundation

/**
 HTTP Provider is the protocol that defines an API and the relationship you want to have with it.
 You can define many providers in your app if you have different API (yours and external for instance)
 */
public protocol HTTPProvider {
    
    /**
     The base URL of your API, the link that is common to every request
     */
    var baseURL:URL { get }
    
    /**
     The session used by the provider. A default session is provided, but this can be overriden for custom configurations
     */
    var session:URLSession { get }
    
    /**
     Defaults Headers, those headers can be provided when implementing the protocol. They will be added to each request
     */
    var defaultHeaders:[String:String] { get }
    
    /**
     Addional Parameters, those parameters can be provided when implementing the protocol. They will be added to each request
     */
    var additionalParams:[String:Any] { get }
    
    /**
     Validation function, it is called when a request is received. You can implement a custom validation if you want to define when we should consider the result a failure
     - parameter response: the HTTPURLResponse returned by NSURLSession
     - paramater data: the data that was returned in the response's body
     - parameter error: any error returned by NSURLSession
     - returns: any Error that you would like to pass to consider the result a failure
     */
    func validate(response:HTTPURLResponse, data:Data, error: Error?) -> StreemError?
    
    /**
     A function called if an error is found before a request returns a failure response. It can be used for instance if the error is a HTTP 401 error and that you don't want to proceed
     - parameter error: the error that the request currently holds
     - returns: a boolean that tells us whether or not we should send a result back
     */
    func shouldContinue(with error:StreemError) -> Bool
}


/**
 This HTTP Provider extension gives a default implementation for the basic behavior of a request.
 */
public extension HTTPProvider{
    
    /**
     The default session will occur on the main queue and with its configuration. A default delegate is implemented.
    */
    var session : URLSession {
        get { return URLSession(configuration: .default, delegate: SessionManager.sharedInstance, delegateQueue: OperationQueue.main)}
    }
    
    /**
     Default headers should be left empty
     */
    var defaultHeaders:[String:String]{ get { return [String:String]() } }
    
    /**
     Default params should be left empty
    */
    var additionalParams:[String:Any]{ get { return [String:Any]() } }
    
    
    /**
     Default validation, it will return an StreemError if the HTTP status code is greater than 399 (400+: client errors, 500+: server errors)
     */
    func validate(response:HTTPURLResponse, data:Data, error: Error?) -> StreemError?{
        if let error = error {
            return StreemNetworkingError.errorWith(error: error)
        }else{
            return response.statusCode > 399 ? StreemNetworkingError.errorWith(httpCode: response.statusCode) : nil
        }
    }
    
    /**
     The default implementation of shouldContinue will always return true. It is up to you whether or not you want to stop the request
     */
    func shouldContinue(with error:StreemError) -> Bool{
        return true
    }
    
    
    /**
     This is the method that needs to be called from a provider to send the request.
     - parameter route: the route object that defines the request
     - returns: the request being sent
     */
    public func request(_ route:Route) -> Request {
        
        let path = baseURL.appendingPathComponent(route.path)
        
        var request = URLRequest(url: path)
        
        let error = request.encode(parameters: additionalParams + route.params, encoding: route.encoding)
        guard error == nil else {
            let r = Request(urlRequest: request, provider:self)
            r.onComplete(response: nil, error: error)
            return r
        }
        
        request.httpMethod = route.method.rawValue
        
        let headers = defaultHeaders + route.headers
        headers.forEach({
            request.setValue($1, forHTTPHeaderField: $0)
        })
        
        let r = Request(urlRequest: request, provider:self)
        
        let task = session.dataTask(with: request)
        SessionManager.sharedInstance.requests[task] = r
        task.resume()
        
        return r
    }
}
