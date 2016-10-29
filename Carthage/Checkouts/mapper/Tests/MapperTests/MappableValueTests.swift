import Mapper
import XCTest

final class MappableValueTests: XCTestCase {
    func testNestedMappable() {
        struct Test: Mappable {
            let nest: Nested
            init(map: Mapper) throws {
                try self.nest = map.from(field:"nest")
            }
        }

        struct Nested: Mappable {
            let string: String
            init(map: Mapper) throws {
                try self.string = map.from(field:"string")
            }
        }

        let test = try? Test(map: Mapper(JSON: ["nest": ["string": "hello"]]))
        XCTAssertTrue(test?.nest.string == "hello")
    }

    func testArrayOfMappables() {
        struct Test: Mappable {
            let nests: [Nested]
            init(map: Mapper) throws {
                try self.nests = map.from(field:"nests")
            }
        }

        struct Nested: Mappable {
            let string: String
            init(map: Mapper) throws {
                try self.string = map.from(field:"string")
            }
        }

        let test = try? Test(map: Mapper(JSON: ["nests": [["string": "first"], ["string": "second"]]]))
        XCTAssertTrue(test?.nests.count == 2)
    }

    func testOptionalMappable() {
        struct Test: Mappable {
            let nest: Nested?
            init(map: Mapper) {
                self.nest = map.from(field:"foo")
            }
        }

        struct Nested: Mappable {
            init(map: Mapper) {}
        }

        let test = Test(map: Mapper(JSON: [:]))
        XCTAssertNil(test.nest)
    }

    func testInvalidArrayOfMappables() {
        struct Test: Mappable {
            let nests: [Nested]
            init(map: Mapper) throws {
                try self.nests = map.from(field:"nests")
            }
        }

        struct Nested: Mappable {
            let string: String
            init(map: Mapper) throws {
                try self.string = map.from(field:"string")
            }
        }

        let test = try? Test(map: Mapper(JSON: ["nests": "not an array"]))
        XCTAssertNil(test)
    }

    func testValidArrayOfOptionalMappables() {
        struct Test: Mappable {
            let nests: [Nested]?
            init(map: Mapper) {
                self.nests = map.from(field:"nests")
            }
        }

        struct Nested: Mappable {
            let string: String
            init(map: Mapper) throws {
                try self.string = map.from(field:"string")
            }
        }

        let test = Test(map: Mapper(JSON: ["nests": [["string": "first"], ["string": "second"]]]))
        XCTAssertTrue(test.nests?.count == 2)
    }

    func testMalformedArrayOfMappables() {
        struct Test: Mappable {
            let nests: [Nested]
            init(map: Mapper) throws {
                try self.nests = map.from(field:"nests")
            }
        }

        struct Nested: Mappable {
            let string: String
            init(map: Mapper) throws {
                try self.string = map.from(field:"string")
            }
        }

        let test = try? Test(map: Mapper(JSON: ["nests": [["foo": "first"], ["string": "second"]]]))
        XCTAssertNil(test)
    }

    func testInvalidArrayOfOptionalMappables() {
        struct Test: Mappable {
            let nests: [Nested]?
            init(map: Mapper) {
                self.nests = map.from(field:"nests")
            }
        }

        struct Nested: Mappable {
            let string: String
            init(map: Mapper) throws {
                try self.string = map.from(field:"string")
            }
        }

        let test = Test(map: Mapper(JSON: ["nests": "not an array"]))
        XCTAssertNil(test.nests)
    }

    func testMappableArrayOfKeys() {
        struct Test: Mappable {
            let nest: Nested?
            init(map: Mapper) {
                self.nest = map.from(fields:["a", "b"])
            }
        }

        struct Nested: Mappable {
            let string: String
            init(map: Mapper) throws {
                try self.string = map.from(field:"string")
            }
        }

        let test = Test(map: Mapper(JSON: ["a": ["foo": "bar"], "b": ["string": "hi"]]))
        XCTAssertTrue(test.nest?.string == "hi")
    }

    func testMappableArrayOfKeysReturningNil() {
        struct Test: Mappable {
            let nest: Nested?
            init(map: Mapper) {
                self.nest = map.from(fields:["a", "b"])
            }
        }

        struct Nested: Mappable {
            init(map: Mapper) throws {}
        }

        if let test = Test.from(JSON: [:]) {
            XCTAssertNil(test.nest)
        } else {
            XCTFail("Failed to create Test")
        }
    }

    func testMappableArrayWithRootKey(){
        struct Test: Mappable {
            let value: Int
            init(map: Mapper) throws {
                try value = map |> "value"
            }
        }
        let json = ["foo": ["bar":[["value": 1], ["value": 2], ["value": 3]]]]
        let tests = [Test].from(JSON: json, rootKey:"foo.bar")
        XCTAssertEqual(tests?.count, 3)
        XCTAssertEqual(tests?[2].value, 3)
    }
}
