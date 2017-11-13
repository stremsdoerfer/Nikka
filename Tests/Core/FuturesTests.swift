//
//  FuturesTests.swift
//  Nikka
//
//  Created by Emilien on 10/22/16.
//  Copyright © 2016 Emilien Stremsdoerfer. All rights reserved.
//

import XCTest
@testable import Nikka

class FuturesTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    func testJSONFuture() {
        let provider = TestProvider()
        let ipObs: Future<Any> = provider.request(.ip).responseJSON()

        let expectation = self.expectation(description: "JSON request should succeed")

        ipObs.onComplete { (result: Result<Any>) in
            expectation.fulfill()
            switch result {
            case .success(let json):
                let jsonDict = json as? [String:Any]
                let origin = jsonDict!["origin"] as? String
                XCTAssertNotNil(origin)
                XCTAssertNotEqual(origin, "")
            case .failure(_):
                XCTFail()
            }
        }
        waitForExpectations(timeout: timeout, handler: nil)
    }

    func testDataObs() {
        let provider = TestProvider()
        let ipObs: Future<(HTTPURLResponse, Data)> = provider.request(.ip).response()
        let expectation = self.expectation(description: "JSON request should succeed")

        ipObs.onComplete { (result: Result<(HTTPURLResponse, Data)>) in
            expectation.fulfill()
            switch result {
            case .success(let response, let data):
                XCTAssertEqual(response.statusCode, 200)
                XCTAssertGreaterThan(data.count, 0)
            case .failure(_):
                XCTFail()
            }
        }

        waitForExpectations(timeout: timeout, handler: nil)
    }
    
    func testObjFuture() {
        struct Ip: Decodable {
            let origin: String
        }
        let provider = TestProvider()
        let ipObs: Future<Ip> = provider.request(.ip).responseObject()
        let expectation = self.expectation(description: "Decodable request should succeed")
        
        ipObs.onSuccess { (ip) in
            expectation.fulfill()
            XCTAssert(ip.origin != "")
        }.onError { _ in
            expectation.fulfill()
            XCTFail()
        }
        waitForExpectations(timeout: timeout, handler: nil)
    }
    
    func testVoidFuture(){
        let provider = TestProvider()
        let ipObs: Future<Void> = provider.request(.ip).response()
        let expectation = self.expectation(description: "Void request should succeed")
        
        ipObs.onComplete { (result) in
            expectation.fulfill()
            if result.error != nil {
                XCTFail()
            }
        }
        waitForExpectations(timeout: timeout, handler: nil)
    }
}
