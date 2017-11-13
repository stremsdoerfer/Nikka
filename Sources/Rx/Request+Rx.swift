/* This software is licensed under the Apache 2 license, quoted below.

 Copyright 2016 Emilien Stremsdoerfer <emstre@gmail.com>
 Licensed under the Apache License, Version 2.0 (the "License"); you may not
 use this file except in compliance with the License. You may obtain a copy of
 the License at

 http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
 WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
 License for the specific language governing permissions and limitations under
 the License.
 */

import Foundation
import RxSwift

/**
 Request extension that allows you to get Observabbles as a response
 */
public extension Request {

    /**
     Method that creates an Observable from a basic response
     - returns: Observable<(HTTPURLResponse,Data)> The created observable
     */
    public func response() -> Observable<(HTTPURLResponse, Data)> {
        return Observable.create { observer in
            self.response({ (response: HTTPURLResponse?, data: Data, error: NikkaError?) in
                if let response = response {
                    observer.onNext((response, data))
                    observer.on(.completed)
                } else if let error = error {
                    observer.onError(error)
                } else {
                    observer.onError(NikkaNetworkingError.unknown("Response and error are nil"))
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
        return Observable.create { observer in
            self.responseJSON({ (response: Response<Any>) in
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

    /**
     Method that creates an Observable from a json response
     - returns: Observable<T> The created observable
     */
    func responseObject<T: Decodable>() -> Observable<T> {
        return Observable.create { observer in
            self.responseObject({ (response: Response<T>) in
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

    /**
     Method that creates an Observable from a json response
     - returns: Observable<Void> The created observable
     */
    func response() -> Observable<Void> {
        return Observable.create { observer in
            self.response({ (_, _, error) in
                if let err = error {
                    observer.onError(err)
                } else {
                    observer.onNext(())
                    observer.on(.completed)
                }
            })
            return Disposables.create()
        }
    }
}
