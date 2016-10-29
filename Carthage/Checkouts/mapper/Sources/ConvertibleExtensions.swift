/// These Foundation conformances are acceptable since we already depend on Foundation. No other frameworks
/// Should be important as part of Mapper for default conformances. Consumers should conform any other common
/// Types in an extension in their own projects (e.g. `CGFloat`)
import Foundation

//MARK: - Default Extensions

extension String: DefaultConvertible {}
extension Int: DefaultConvertible {}
extension UInt: DefaultConvertible {}
extension Float: DefaultConvertible {}
extension Double: DefaultConvertible {}
extension Bool: DefaultConvertible {}
extension NSNumber: DefaultConvertible{}
extension NSDictionary: DefaultConvertible {}
extension NSArray: DefaultConvertible {}

// MARK: - NSDate Extension

/**
 NSDate Convertible implementation
 */
extension Date : Convertible{

    /**
     Create a NSDate from Mapper

     - parameter value: The timestamp passed from Mapper
     - throws: MapperError.ConvertibleError if the passed value is not an TimeInterval
     - returns: The date created with the timestamp
     */
    public static func from(value: Any?) throws -> Date {
        guard let timestamp = value as? TimeInterval else {
            throw MapperError.convertibleError(value: value, type: TimeInterval.self)
        }
        return Date(timeIntervalSince1970: timestamp)
    }

    /**
     Create a NSDate from Mapper

     - parameter value: The string passed from Mapper
     - throws: MapperError.ConvertibleError if the passed value is not a String or DateFormatter returns nil
     - returns: The date created with the timestamp
    */
    public static func from(value: Any?, format: String) throws -> Date {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        if let date = (value as? String).flatMap({formatter.date(from: $0)}) {
            return date
        } else{
            throw MapperError.convertibleError(value: value, type: Date.self)
        }
    }
}

// MARK: - NSURL Extension

/**
 NSURL Convertible implementation
 */
extension URL: Convertible {
    /**
     Create a NSURL from Mapper

     - parameter value: The object (or nil) passed from Mapper
     - throws: MapperError.ConvertibleError if the passed value is not a String
     - throws: MapperError.CustomError      if the passed value a String but the NSURL initializer returns nil
     - returns: The created NSURL
     */
    public static func from(value: Any?) throws -> URL {
        guard let string = value as? String else {
            throw MapperError.convertibleError(value: value, type: String.self)
        }

        if let URL = URL(string: string) {
            return URL
        }

        throw MapperError.customError(field: nil, message: "'\(string)' is not a valid NSURL")
    }
}

// MARK: - Numbers Extensions

/**
 Int64 Convertible implementation
 */
extension Int64:Convertible{

    /**
     Create a Int64 from Mapper

     - parameter value: The object (or nil) passed from Mapper
     - throws: MapperError.ConvertibleError if the passed value is not a Number
     - returns: The created Int64
     */
    public static func from(value: Any?) throws -> Int64 {
        guard let number = value as? NSNumber else {
            throw MapperError.convertibleError(value: value, type: Int64.self)
        }
        return number.int64Value
    }
}

/**
 UInt64 Convertible implementation
 */
extension UInt64:Convertible{

    /**
     Create a UInt64 from Mapper

     - parameter value: The object (or nil) passed from Mapper
     - throws: MapperError.ConvertibleError if the passed value is not a Number
     - returns: The created UInt64
     */
    public static func from(value: Any?) throws -> UInt64 {
        guard let number = value as? NSNumber else {
            throw MapperError.convertibleError(value: value, type: UInt64.self)
        }
        return number.uint64Value
    }
}

/**
 Int32 Convertible implementation
 */
extension Int32:Convertible{

    /**
     Create a Int32 from Mapper

     - parameter value: The object (or nil) passed from Mapper
     - throws: MapperError.ConvertibleError if the passed value is not a Number
     - returns: The created Int32
     */
    public static func from(value: Any?) throws -> Int32 {
        guard let number = value as? NSNumber else {
            throw MapperError.convertibleError(value: value, type: Int32.self)
        }
        return number.int32Value
    }
}

/**
 UInt32 Convertible implementation
 */
extension UInt32:Convertible{

    /**
     Create a UInt32 from Mapper

     - parameter value: The object (or nil) passed from Mapper
     - throws: MapperError.ConvertibleError if the passed value is not a Number
     - returns: The created UInt32
     */
    public static func from(value: Any?) throws -> UInt32 {
        guard let number = value as? NSNumber else {
            throw MapperError.convertibleError(value: value, type: UInt32.self)
        }
        return number.uint32Value
    }
}

/**
 Int16 Convertible implementation
 */
extension Int16:Convertible{

    /**
     Create a Int16 from Mapper

     - parameter value: The object (or nil) passed from Mapper
     - throws: MapperError.ConvertibleError if the passed value is not a Number
     - returns: The created Int16
     */
    public static func from(value: Any?) throws -> Int16 {
        guard let number = value as? NSNumber else {
            throw MapperError.convertibleError(value: value, type: Int16.self)
        }
        return number.int16Value
    }
}

/**
 UInt16 Convertible implementation
 */
extension UInt16:Convertible{

    /**
     Create a UInt16 from Mapper

     - parameter value: The object (or nil) passed from Mapper
     - throws: MapperError.ConvertibleError if the passed value is not a Number
     - returns: The created UInt16
     */
    public static func from(value: Any?) throws -> UInt16 {
        guard let number = value as? NSNumber else {
            throw MapperError.convertibleError(value: value, type: UInt16.self)
        }
        return number.uint16Value
    }
}

/**
 Int8 Convertible implementation
 */
extension Int8:Convertible{

    /**
     Create a Int8 from Mapper

     - parameter value: The object (or nil) passed from Mapper
     - throws: MapperError.ConvertibleError if the passed value is not a Number
     - returns: The created Int8
     */
    public static func from(value: Any?) throws -> Int8 {
        guard let number = value as? NSNumber else {
            throw MapperError.convertibleError(value: value, type: Int8.self)
        }
        return number.int8Value
    }
}

/**
 UInt8 Convertible implementation
 */
extension UInt8:Convertible{

    /**
     Create a UInt8 from Mapper

     - parameter value: The object (or nil) passed from Mapper
     - throws: MapperError.ConvertibleError if the passed value is not a Number
     - returns: The created UInt8
     */
    public static func from(value: Any?) throws -> UInt8 {
        guard let number = value as? NSNumber else {
            throw MapperError.convertibleError(value: value, type: UInt8.self)
        }
        return number.uint8Value
    }
}
