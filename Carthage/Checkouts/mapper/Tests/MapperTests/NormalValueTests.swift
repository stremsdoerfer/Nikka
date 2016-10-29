import Mapper
import XCTest

final class NormalValueTests: XCTestCase {
    func testMappingString() {
        struct Test: Mappable {
            let string: String
            init(map: Mapper) throws {
                try self.string = map.from(field:"string")
            }
        }

        let test = try? Test(map: Mapper(JSON: ["string": "Hello"]))
        XCTAssertTrue(test?.string == "Hello")
    }

    func testValueBoolean() {
        struct Test: Mappable {
            let value: Bool
            init(map: Mapper) throws {
                try self.value = map.from(field:"value")
            }
        }

        let test = try? Test(map: Mapper(JSON: ["value": true]))
        XCTAssertTrue(test!.value)
    }

    func testMappingTimeInterval() {
        struct Test: Mappable {
            let string: TimeInterval
            init(map: Mapper) throws {
                try self.string = map.from(field:"time")
            }
        }

        let test = try? Test(map: Mapper(JSON: ["time": 123]))
        XCTAssertTrue(test?.string == 123)
    }

    func testMappingMissingKey() {
        struct Test: Mappable {
            let string: String
            init(map: Mapper) throws {
                try self.string = map.from(field:"foo")
            }
        }

        let test = try? Test(map: Mapper(JSON: [:]))
        XCTAssertNil(test)
    }

    func testFallbackMissingKey() {
        struct Test: Mappable {
            let string: String
            init(map: Mapper) {
                self.string = map.from(field:"foo") ?? "Hello"
            }
        }

        let test = Test(map: Mapper(JSON: [:]))
        XCTAssertTrue(test.string == "Hello")
    }

    func testArrayOfStrings() {
        struct Test: Mappable {
            let strings: [String]
            init(map: Mapper) throws {
                try self.strings = map.from(field:"strings")
            }
        }

        let test = try? Test(map: Mapper(JSON: ["strings": ["first", "second"]]))
        XCTAssertTrue(test?.strings.count == 2)
    }

    func testEmptyStringJSON() {
        struct Test: Mappable {
            let JSON: NSDictionary
            init(map: Mapper) throws {
                try self.JSON = map.from(field:"")
            }
        }

        let JSON = ["a": "b", "c": "d"]
        let test = try? Test(map: Mapper(JSON: JSON as NSDictionary))
        let parsedJSON = test?.JSON as? [String: String] ?? [:]
        XCTAssertTrue(parsedJSON == JSON)
    }

    func testKeyPath() {
        struct Test: Mappable {
            let string: String
            init(map: Mapper) throws {
                try self.string = map.from(field:"foo.bar")
            }
        }

        let test = try? Test(map: Mapper(JSON: ["foo": ["bar": "baz"]]))
        XCTAssertTrue(test?.string == "baz")
    }

    func testPartiallyInvalidArrayOfValues() {
        struct Test: Mappable {
            let strings: [String]
            init(map: Mapper) throws {
                try self.strings = map.from(field:"strings")
            }
        }

        let test = try? Test(map: Mapper(JSON: ["strings": ["hi", 1]]))
        XCTAssertNil(test)
    }

    func testOptionalPropertyWithFrom() {
        struct Test: Mappable {
            let string: String?
            init(map: Mapper) throws {
                self.string = map.from(field:"string")
            }
        }

        let test = try? Test(map: Mapper(JSON: ["string": "hi"]))
        XCTAssertEqual(test?.string, "hi")
    }

    func testNestedKeysWithInvalidType() {
        struct Test: Mappable {
            let string: String
            init(map: Mapper) throws {
                try self.string = map.from(field:"user.phone")
            }
        }

        let test = try? Test(map: Mapper(JSON: ["user": "not dictionary"]))
        XCTAssertNil(test)
    }
}
