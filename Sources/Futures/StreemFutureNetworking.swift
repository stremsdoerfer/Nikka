//
//  StreemFutureNetworking.swift
//  StreemNetworking
//
//  Created by Emilien on 10/16/16.
//  Copyright © 2016 Emilien Stremsdoerfer. All rights reserved.
//

import Foundation

/**
 Request extension that allows you to get Future out of a standard and a JSON response
 */
public extension Request {
    
    /**
     Method that creates a Future from the basic response
     - returns: Future<(HTTPURLResponse,Data)> The created future
     */
    public func response() -> Future<(HTTPURLResponse,Data)>{
        let future = Future<(HTTPURLResponse, Data)>()

        self.progress({ (receivedSize, expectedSize) in
            future.fill(progress: (receivedSize, expectedSize))
        }).response { (response:HTTPURLResponse?, data:Data, error:StreemError?) in
            if let response = response {
                future.fill(result: .success(response,data))
            }else if let error = error {
                future.fill(result: .failure(error))
            }else {
                future.fill(result: .failure(StreemNetworkingError.unknown("Response and error are nil")))
            }
        }
        
        return future
    }
    
    /**
     Method that creates an Future from the json response
     - returns: Future<Any> The created future
     */
    public func responseJSON() -> Future<Any> {
        let future = Future<Any>()
        self.progress { (receivedSize, expectedSize) in
            future.fill(progress: (receivedSize, expectedSize))
        }.responseJSON { (response:Response<Any>) in
            future.fill(result: response.result)
        }
        return future
    }
    
}
