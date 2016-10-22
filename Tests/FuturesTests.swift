//
//  FuturesTests.swift
//  StreemNetworking
//
//  Created by Emilien on 10/22/16.
//  Copyright © 2016 Emilien Stremsdoerfer. All rights reserved.
//

import XCTest
@testable import StreemNetworking

class FuturesTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    func testJSONFuture(){
        let provider = TestProvider()
        let ipObs:Future<Any> = provider.request(.ip).responseJSON()
        
        let expectation = self.expectation(description: "JSON request should succeed")
        
        ipObs.onComplete { (result:Result<Any>) in
            expectation.fulfill()
            switch result{
            case .success(let json):
                let jsonDict = json as! [String:Any]
                XCTAssertNotNil(jsonDict["origin"])
                XCTAssertNotEqual(jsonDict["origin"] as! String, "")
            case .failure(_):
                XCTFail()
            }
        }
        waitForExpectations(timeout: timeout, handler: nil)
    }
    
    func testDataObs(){
        let provider = TestProvider()
        let ipObs:Future<(HTTPURLResponse,Data)> = provider.request(.ip).response()
        let expectation = self.expectation(description: "JSON request should succeed")
        
        ipObs.onComplete { (result:Result<(HTTPURLResponse, Data)>) in
            expectation.fulfill()
            switch result{
            case .success(let response, let data):
                XCTAssertEqual(response.statusCode, 200)
                XCTAssertGreaterThan(data.count, 0)
            case .failure(_):
                XCTFail()
            }
        }

        waitForExpectations(timeout: timeout, handler: nil)
    }
}
