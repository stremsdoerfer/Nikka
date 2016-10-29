import Mapper
import XCTest

private struct Foo: Convertible {
    static func from(value: Any?) throws -> Foo {
        return Foo()
    }
}

final class ConvertibleValueTests: XCTestCase {
    func testCreatingURL() {
        struct Test: Mappable {
            let URL: Foundation.URL
            init(map: Mapper) throws {
                try self.URL = map.from(field:"url")
            }
        }

        let test = try? Test(map: Mapper(JSON: ["url": "https://google.com"]))
        XCTAssertTrue(test?.URL.host == "google.com")
    }

    func testOptionalURL() {
        struct Test: Mappable {
            let URL: Foundation.URL?
            init(map: Mapper) {
                self.URL = map.from(field:"url")
            }
        }

        let test = Test(map: Mapper(JSON: ["url": "https://google.com"]))
        XCTAssertTrue(test.URL?.host == "google.com")
    }

    func testInvalidURL() {
        struct Test: Mappable {
            let URL: Foundation.URL?
            init(map: Mapper) {
                self.URL = map.from(field:"url")
            }
        }

        let test = Test(map: Mapper(JSON: ["url": "##"]))
        XCTAssertNil(test.URL)
    }

    func testArrayOfConvertibles() {
        struct Test: Mappable {
            let URLs: [URL]
            init(map: Mapper) throws {
                try self.URLs = map.from(field:"urls")
            }
        }

        let test = try? Test(map: Mapper(JSON: ["urls": ["https://google.com", "example.com"]]))
        XCTAssertTrue(test?.URLs.count == 2)
    }

    func testOptionalArrayOfConvertibles() {
        struct Test: Mappable {
            let URLs: [URL]?
            init(map: Mapper) {
                self.URLs = map.from(field:"urls")
            }
        }

        let test = Test(map: Mapper(JSON: [:]))
        XCTAssertNil(test.URLs)
    }

    func testExistingOptionalArrayOfConvertibles() {
        struct Test: Mappable {
            let URLs: [URL]?
            init(map: Mapper) {
                self.URLs = map.from(field:"urls")
            }
        }

        let test = Test(map: Mapper(JSON: ["urls": ["https://google.com", "example.com"]]))
        XCTAssertTrue(test.URLs?.count == 2)
    }

    func testInvalidArrayOfConvertibles() {
        struct Test: Mappable {
            let URLs: [URL]
            init(map: Mapper) throws {
                try self.URLs = map.from(field:"urls")
            }
        }

        let test = try? Test(map: Mapper(JSON: ["urls": "not an array"]))
        XCTAssertNil(test)
    }

    func testInvalidArrayOfOptionalConvertibles() {
        struct Test: Mappable {
            let URLs: [URL]?
            init(map: Mapper) {
                self.URLs = map.from(field:"urls")
            }
        }

        let test = Test(map: Mapper(JSON: ["urls": "not an array"]))
        XCTAssertNil(test.URLs)
    }

    func testConvertibleArrayOfKeys() {
        struct Test: Mappable {
            let URL: Foundation.URL?
            init(map: Mapper) {
                self.URL = map.from(fields:["a", "b"])
            }
        }

        let test = Test(map: Mapper(JSON: ["a": "##", "b": "example.com"]))
        XCTAssertTrue(test.URL?.absoluteString == "example.com")
    }

    func testConvertibleArrayOfKeysReturnsNil() {
        struct Test: Mappable {
            let URL: Foundation.URL?
            init(map: Mapper) {
                self.URL = map.from(fields:["a", "b"])
            }
        }

        let test = Test(map: Mapper(JSON: [:]))
        XCTAssertNil(test.URL)
    }

    func testDictionaryConvertible() {
        struct Test: Mappable {
            let dictionary: [String: Int]

            init(map: Mapper) throws {
                try self.dictionary = map.from(field:"foo")
            }
        }

        let test = Test.from(JSON: ["foo": ["key": 1]])
        XCTAssertTrue(test?.dictionary["key"] == 1)
    }

    func testOptionalDictionaryConvertible() {
        struct Test: Mappable {
            let dictionary: [String: Int]?

            init(map: Mapper) throws {
                self.dictionary = map.from(field:"foo")
            }
        }

        let test = Test.from(JSON: ["foo": ["key": 1]])
        XCTAssertTrue(test?.dictionary?["key"] == 1)
    }

    func testDictionaryOfConvertibles() {
        struct Test: Mappable {
            let dictionary: [String: Foo]

            init(map: Mapper) throws {
                try self.dictionary = map.from(field:"foo")
            }
        }

        let test = Test.from(JSON: ["foo": ["key": "value"]])
        XCTAssertTrue(test!.dictionary.count > 0)
    }

    func testOptionalDictionaryConvertibleNil() {
        struct Test: Mappable {
            let dictionary: [String: Int]?

            init(map: Mapper) throws {
                self.dictionary = map.from(field:"foo")
            }
        }

        do {
            let test = try Test(map: Mapper(JSON: ["foo": ["key": "not int"]]))
            XCTAssertNil(test.dictionary)
        } catch {
            XCTFail("Couldn't create Test")
        }
    }

    func testDictionaryConvertibleSingleInvalid() {
        struct Test: Mappable {
            let dictionary: [String: Int]

            init(map: Mapper) throws {
                try self.dictionary = map.from(field:"foo")
            }
        }

        let test = Test.from(JSON: ["foo": ["key": 1, "key2": "not int"]])
        XCTAssertNil(test)
    }

    func testDictionaryButInvalidJSON() {
        struct Test: Mappable {
            let dictionary: [String: Int]

            init(map: Mapper) throws {
                try self.dictionary = map.from(field:"foo")
            }
        }

        let test = Test.from(JSON: ["foo": "not a dictionary"])
        XCTAssertNil(test)
    }

    func testDateWithTimestamp() {
        struct Test: Mappable{
            let date: Date

            init(map: Mapper) throws {
                try date = map |> "date"
            }
        }
        let test = Test.from(JSON: ["date": 1475975039])
        XCTAssertNotNil(test)
    }

    func testOptionalDateWithTimestamp() {
        struct Test: Mappable{
            let date: Date?

            init(map: Mapper) throws {
                date = map |> "date"
            }
        }
        let test = Test.from(JSON: ["date": 1475975039])
        XCTAssertNotNil(test?.date)
    }

    func testDateWithFormat() {
        struct Test: Mappable{
            let date: Date

            init(map: Mapper) throws {
                try date = map |> ("date", "MMMM dd, yyyy h:mm:ss a zzz")
            }
        }
        let test = Test.from(JSON: ["date": "June 30, 2009 7:03:47 AM PDT"])
        XCTAssertNotNil(test)
    }

    func testOptionalDateWithFormat() {
        struct Test: Mappable{
            let date: Date?

            init(map: Mapper) throws {
                date = map |> ("date", "MMMM dd, yyyy h:mm:ss a zzz")
            }
        }
        let test = Test.from(JSON: ["date": "June 30, 2009 7:03:47 AM PDT"])
        XCTAssertNotNil(test?.date)
    }

    func testInvalidDateWithFormat() {
        struct Test: Mappable{
            let date: Date?

            init(map: Mapper) throws {
                date = map |> ("date", "wrong format")
            }
        }
        let test = Test.from(JSON: ["date": "June 30, 2009 7:03:47 AM PDT"])
        XCTAssertNil(test?.date)
    }
}
