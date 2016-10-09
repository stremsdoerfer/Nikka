//
//  StreemRxNetworkin.swift
//  StreemNetworking
//
//  Created by Emilien on 10/8/16.
//  Copyright © 2016 Emilien Stremsdoerfer. All rights reserved.
//

import Foundation
import RxSwift
import Mapper

public extension Request{
    
    func response<T: Mappable>() -> Observable<T>{
        return Observable.create{ observer in
            self.responseObject({ (response:Response<T>) in
                switch response.result{
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
    
    func response<T: Mappable>() -> Observable<[T]>{
        return Observable.create{ observer in
            self.responseArray({ (response:Response<[T]>) in
                switch response.result{
                case .success(let values):
                    observer.onNext(values)
                    observer.on(.completed)
                case .failure(let error):
                    observer.onError(error)
                }
            })
            return Disposables.create()
        }
    }
}
