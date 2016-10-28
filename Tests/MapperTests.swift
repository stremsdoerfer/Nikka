//
//  MapperTests.swift
//  StreemNetworking
//
//  Created by Emilien on 10/15/16.
//  Copyright © 2016 Emilien Stremsdoerfer. All rights reserved.
//

import XCTest
@testable import StreemNetworking
@testable import StreemMapper

class MapperTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    func testDeserializeObject() {
        struct TestIP: Mappable {
            let ip: String

            init(map: Mapper) throws {
                try ip = map |> "origin"
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

    func testDeserializeArray() {
        struct TestValue: Mappable {
            let value: Int

            init(map: Mapper) throws {
                try value = map |> "value"
            }
        }

        let expectation = self.expectation(description: "GET request should succeed")

        let provider = TestProvider()
        let json = ["test":[["value":1], ["value":2], ["value":3]]]
        provider.request(.postJSON(json)).responseArray(rootKey: "json.test") { (response: Response<[TestValue]>) in
            expectation.fulfill()
            XCTAssertNil(response.result.error)
            XCTAssertNotNil(response.result.value)
            XCTAssertEqual(response.result.value?.count, 3)
            XCTAssertEqual(response.result.value?[2].value, 3)
        }
        waitForExpectations(timeout: timeout, handler: nil)
    }

    func testDeserializeObjectError() {
        struct TestIP: Mappable {
            let ip: String

            init(map: Mapper) throws {
                try ip = map |> "blah"
            }
        }

        let expectation = self.expectation(description: "GET request should succeed")

        let provider = TestProvider()
        provider.request(.ip).responseObject { (response: Response<TestIP>) in
            expectation.fulfill()
            XCTAssertNil(response.result.value)
            XCTAssertTrue((response.result.error?.isEqual(err:StreemNetworkingError.jsonMapping("")))!)
        }

        waitForExpectations(timeout: timeout, handler: nil)
    }

    func testDeserializeArrayError() {
        struct TestValue: Mappable {
            let value: Int

            init(map: Mapper) throws {
                try value = map |> "value"
            }
        }

        let expectation = self.expectation(description: "GET request should succeed")

        let provider = TestProvider()
        let json = ["blah":[["value":1], ["value":2], ["value":3]]]
        provider.request(.postJSON(json)).responseArray(rootKey: "json.test") { (response: Response<[TestValue]>) in
            expectation.fulfill()
            XCTAssertNil(response.result.value)
            XCTAssertTrue((response.result.error?.isEqual(err:StreemNetworkingError.jsonMapping("")))!)
        }
        waitForExpectations(timeout: timeout, handler: nil)
    }
}
