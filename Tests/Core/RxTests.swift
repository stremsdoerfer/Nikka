//
//  RxTests.swift
//  Nikka
//
//  Created by Emilien on 10/22/16.
//  Copyright © 2016 Emilien Stremsdoerfer. All rights reserved.
//

import XCTest
@testable import Nikka
@testable import RxSwift

class RxTests: XCTestCase {

    let bag = DisposeBag()

    func testJSONObs() {
        let provider = TestProvider()
        let ipObs: Observable<Any> = provider.request(.ip).responseJSON()

        let expectation = self.expectation(description: "JSON request should succeed")

        ipObs.subscribe(onNext: { json in
            expectation.fulfill()
            guard let jsonDict = json as? [String:Any], let ip = jsonDict["origin"] as? String else {
                XCTFail()
                return
            }
            XCTAssertNotEqual(ip, "")
        }).disposed(by: bag)

        waitForExpectations(timeout: timeout, handler: nil)
    }

    func testDataObs() {
        let provider = TestProvider()
        let ipObs: Observable<(HTTPURLResponse, Data)> = provider.request(.ip).response()
        let expectation = self.expectation(description: "JSON request should succeed")

        ipObs.subscribe(onNext: { (response: (HTTPURLResponse, Data)) in
            expectation.fulfill()
            XCTAssertEqual(response.0.statusCode, 200)
            let object = try? JSONSerialization.jsonObject(with: response.1, options: .allowFragments)
            XCTAssertNotNil(object)
        }).disposed(by: bag)

        waitForExpectations(timeout: timeout, handler: nil)
    }

    func testObjObs() {
        struct Ip: Decodable {
            let origin: String
        }
        let provider = TestProvider()
        let ipObs: Observable<Ip> = provider.request(.ip).responseObject()
        let expectation = self.expectation(description: "Decodable request should succeed")
        
        ipObs.subscribe(onNext: { (ip) in
            expectation.fulfill()
            XCTAssert(ip.origin != "")
        }, onError: { _ in
            expectation.fulfill()
            XCTFail()
        }).disposed(by: bag)

        waitForExpectations(timeout: timeout, handler: nil)
    }
    
    func testVoidObs(){
        let provider = TestProvider()
        let ipObs: Observable<Void> = provider.request(.ip).response()
        let expectation = self.expectation(description: "Void request should succeed")
        
        ipObs.subscribe(onNext: { _ in
            expectation.fulfill()
        }, onError: { _ in
            expectation.fulfill()
            XCTFail()
        }).disposed(by: bag)

        waitForExpectations(timeout: timeout, handler: nil)
    }
}
