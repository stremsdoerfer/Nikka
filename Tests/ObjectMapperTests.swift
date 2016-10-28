//
//  ObjectMapperTests.swift
//  StreemNetworking
//
//  Created by Emilien on 10/15/16.
//  Copyright © 2016 Emilien Stremsdoerfer. All rights reserved.
//

import XCTest
@testable import StreemNetworking
@testable import ObjectMapper

class ObjectMapperTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    func testDeserializeObject() {
        struct TestIP: Mappable {
            var ip: String?

            init?(map: Map) { }

            mutating func mapping(map: Map) {
                ip <- map["origin"]
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

        waitForExpectations(timeout: timeout, handler: nil)
    }

    func testDeserializeObjectError() {
        struct TestIP: Mappable {
            var ip: String?

            init?(map: Map) {
                ip <- map["blah"]
                if ip == nil {
                    return nil
                }
            }

            mutating func mapping(map: Map) {
                ip <- map["blah"]
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
