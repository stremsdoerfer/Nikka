//
//  GlossTests.swift
//  StreemNetworking
//
//  Created by Emilien on 10/21/16.
//  Copyright © 2016 Emilien Stremsdoerfer. All rights reserved.
//

import XCTest
@testable import StreemNetworking
@testable import Gloss

class GlossTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    func testDeserializeObject() {
        struct TestIP: Decodable {
            let ip: String

            init?(json: JSON) {
                guard let ip: String = "origin" <~~ json else {
                    return nil
                }
                self.ip = ip
            }
        }

        let expectation = self.expectation(description: "GET request should succeed")

        let provider = TestProvider()
        provider.request(.ip).responseObject { (response: Response<TestIP>) in
            expectation.fulfill()
            XCTAssertNil(response.result.error)
            XCTAssertNotNil(response.result.value)
            XCTAssertNotEqual(response.result.value?.ip, "")
        }

        waitForExpectations(timeout: timeout+1, handler: nil)
    }

    func testDeserializeObjectError() {
        struct TestIP: Decodable {
            let ip: String

            init?(json: JSON) {
                guard let ip: String = "blah" <~~ json else {
                    return nil
                }
                self.ip = ip
            }
        }

        let expectation = self.expectation(description: "GET request should fail")

        let provider = TestProvider()
        provider.request(.ip).responseObject { (response: Response<TestIP>) in
            expectation.fulfill()
            XCTAssertNil(response.result.value)
            XCTAssertTrue((response.result.error?.isEqual(err: StreemNetworkingError.jsonMapping("")))!)
        }

        waitForExpectations(timeout: timeout, handler: nil)
    }
}
