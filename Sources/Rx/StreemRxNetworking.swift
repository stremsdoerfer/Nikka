//
//  StreemRxNetworking.swift
//  StreemNetworking
//
//  Created by Emilien on 10/16/16.
//  Copyright © 2016 Emilien Stremsdoerfer. All rights reserved.
//

import Foundation
import RxSwift

/**
 Request extension that allows you to get Observabbles as a response
 */
public extension Request{
    
    /**
     Method that creates an Observable from a basic response
     - returns: Observable<(HTTPURLResponse,Data)> The created observable
     */
    public func response() -> Observable<(HTTPURLResponse,Data)> {
        return Observable.create{ observer in
            self.response({ (response:HTTPURLResponse?, data:Data, error:StreemError?) in
                if let response = response {
                    observer.onNext((response, data))
                    observer.on(.completed)
                }else if let error = error {
                    observer.onError(error)
                }else{
                    observer.onError(StreemNetworkingError.unknown("Response and error are nil"))
                }
            })
            return Disposables.create()
        }
    }
    
    /**
     Method that creates an Observable from a json response
     - returns: Observable<Any> The created observable
     */
    public func responseJSON() -> Observable<Any> {
        return Observable.create{ observer in
            self.responseJSON({ (response:Response<Any>) in
                switch response.result {
                case .success(let value):
                    observer.onNext(value)
                    observer.on(.completed)
                case .failure(let error):
                    observer.onError(error)
                }
            })
            return Disposables.create()
        }
    }
}

