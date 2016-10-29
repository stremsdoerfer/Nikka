import Foundation

/**
 Mapper creates strongly typed objects from a given NSDictionary based on the mapping provided by implementing
 the Mappable protocol (see `Mappable` for an example).
 */
public struct Mapper {
    fileprivate let JSON: NSDictionary

    /**
     Create a Mapper with a NSDictionary to use as source data

     - parameter JSON: The dictionary to use for the data
     */

    public init(JSON: NSDictionary) {
        self.JSON = JSON
    }

    // MARK: - T: RawRepresentable

    /**
     Get a RawRepresentable value from the given field in the source data

     This allows you to transparently create instances of enums and other RawRepresentables from source data

     - parameter field: The field to retrieve from the source data, can be an empty string to return the
                        entire data set

     - throws: MapperError.MissingFieldError    if the field doesn't exist
     - throws: MapperError.TypeMismatchError    if the value exists but doesn't match the type of the RawValue
     - throws: MapperError.InvalidRawValueError if the value exists with the correct type, but the type's
                                                initializer fails with the passed rawValue

     - returns: The value for the given field, if it can be converted to the expected type T
     */

    public func from<T: RawRepresentable>(field: String) throws -> T {
        let object = try self.JSONFrom(field:field)
        guard let rawValue = object as? T.RawValue else {
            throw MapperError.typeMismatchError(field: field, value: object, type: T.RawValue.self)
        }

        guard let value = T(rawValue: rawValue) else {
            throw MapperError.invalidRawValueError(field: field, value: rawValue, type: T.self)
        }

        return value
    }

    /**
     Get an optional RawRepresentable value from the given field in the source data

     This allows you to transparently create instances of enums and other RawRepresentables from source data

     - parameter field: The field to retrieve from the source data, can be an empty string to return the
                        entire data set

     - returns: The value for the given field, if it can be converted to the expected type T otherwise nil
     */

    public func from<T: RawRepresentable>(field: String) -> T? {
        return try? self.from(field:field)
    }

    /**
     Get an optional value from the given fields and source data. This returns the first non-nil value
     produced in order based on the array of fields

     - parameter fields: The array of fields to check from the source data.

     - returns: The first non-nil value to be produced from the array of fields, or nil if none exist
     */

    public func from<T: RawRepresentable>(fields: [String]) -> T? {
        for field in fields {
            if let value: T = try? self.from(field:field) {
                return value
            }
        }

        return nil
    }

    /**
     Get an array of RawRepresentable values from a field in the the source data.

     - note: If T.init(rawValue:) fails given the T.RawValue from the array of source data, that value will be
             replaced by the passed defaultValue, which defaults to nil. The resulting array is flatMapped and
             all nils are removed. This means that any unrecognized values will be removed or replaced with a
             default. This ensures backwards compatibility if your source data has keys that your mapping
             layer doesn't know about yet.

     - parameter field:        The field to use from the source data
     - parameter defaultValue: The value to use if the rawValue initializer fails

     - throws: MapperError.TypeMismatchError when the value for the key is not an array of Any
     - throws: Any other error produced by a Convertible implementation

     - returns: An array of the RawRepresentable value, with all nils removed
     */

    public func from<T: RawRepresentable>(field: String, defaultValue: T? = nil) throws -> [T]
        where T.RawValue: Convertible, T.RawValue == T.RawValue.ConvertedType
    {
        let value = try self.JSONFrom(field:field)
        guard let array = value as? [Any] else {
            throw MapperError.typeMismatchError(field: field, value: value, type: [Any].self)
        }

        let rawValues = try array.map { try T.RawValue.from(value:$0) }
        return rawValues.flatMap { T(rawValue: $0) ?? defaultValue }
    }

    /**
     Get an array of RawRepresentable values from a field in the the source data.

     - note: If T.init(rawValue:) fails given the T.RawValue from the array of source data, that value will be
     replaced by the passed defaultValue, which defaults to nil. The resulting array is flatMapped and
     all nils are removed. This means that any unrecognized values will be removed or replaced with a
     default. This ensures backwards compatibility if your source data has keys that your mapping
     layer doesn't know about yet.
     - parameter field:        The field to use from the source data
     - parameter defaultValue: The value to use if the rawValue initializer fails
     - returns: An array of the RawRepresentable value, with all nils removed.
                Nil if cannot be converted
     */

    public func from<T: RawRepresentable>(field: String, defaultValue: T? = nil) -> [T]?
        where T.RawValue: Convertible, T.RawValue == T.RawValue.ConvertedType
    {
        if let value = try? self.JSONFrom(field:field), let array = value as? [Any] {
            let rawValues = try? array.map { try T.RawValue.from(value:$0) }
            return rawValues?.flatMap { T(rawValue: $0) ?? defaultValue }
        }
        return nil
    }

    // MARK: - T: Mappable

    /**
     Get a Mappable value from the given field in the source data

     This allows you to transparently have nested Mappable values

     - parameter field: The field to retrieve from the source data, can be an empty string to return the
                        entire data set

     - throws: MapperError.MissingFieldError if the field doesn't exist
     - throws: MapperError.TypeMismatchError if the field exists but isn't an NSDictionary

     - returns: The value for the given field, if it can be converted to the expected type T
     */

    public func from<T: Mappable>(field: String) throws -> T {
        let value = try self.JSONFrom(field:field)
        if let JSON = value as? NSDictionary {
            return try T(map: Mapper(JSON: JSON))
        }

        throw MapperError.typeMismatchError(field: field, value: value, type: NSDictionary.self)
    }

    /**
     Get an array of Mappable values from the given field in the source data

     This allows you to transparently have nested arrays of Mappable values

     - note: If any value in the array of NSDictionaries is invalid, this method throws

     - parameter field: The field to retrieve from the source data, can be an empty string to return the
                        entire data set

     - throws: MapperError.MissingFieldError if the field doesn't exist
     - throws: MapperError.TypeMismatchError if the field exists but isn't an array of NSDictionarys
     - throws: Any errors produced by the subsequent Mappable initializers

     - returns: The value for the given field, if it can be converted to the expected type [T]
     */

    public func from<T: Mappable>(field: String) throws -> [T] {
        let value = try self.JSONFrom(field:field)
        if let JSON = value as? [NSDictionary] {
            return try JSON.map { try T(map: Mapper(JSON: $0)) }
        }

        throw MapperError.typeMismatchError(field: field, value: value, type: [NSDictionary].self)
    }

    /**
     Get an optional Mappable value from the given field in the source data

     This allows you to transparently have nested Mappable values

     - parameter field: The field to retrieve from the source data, can be an empty string to return the
                        entire data set

     - returns: The value for the given field, if it can be converted to the expected type T otherwise nil
     */

    public func from<T: Mappable>(field: String) -> T? {
        return try? self.from(field:field)
    }

    /**
     Get an optional array of Mappable values from the given field in the source data

     This allows you to transparently have nested arrays of Mappable values

     - note: If any value in the provided array of NSDictionaries is invalid, this method returns nil

     - parameter field: The field to retrieve from the source data, can be an empty string to return the
                        entire data set

     - returns: The value for the given field, if it can be converted to the expected type [T]
     */

    public func from<T: Mappable>(field: String) -> [T]? {
        return try? self.from(field:field)
    }

    /**
     Get an optional value from the given fields and source data. This returns the first non-nil value
     produced in order based on the array of fields

     - parameter fields: The array of fields to check from the source data.

     - returns: The first non-nil value to be produced from the array of fields, or nil if none exist
     */

    public func from<T: Mappable>(fields: [String]) -> T? {
        for field in fields {
            if let value: T = try? self.from(field:field) {
                return value
            }
        }

        return nil
    }

    // MARK: - T: Convertible

    /**
     Get a Convertible value from a field in the source data

     This transparently converts your types that conform to Convertible to properties on the Mappable type

     - parameter field: The field to retrieve from the source data, can be an empty string to return the
                        entire data set

     - throws: Any error produced by the custom Convertible implementation

     - returns: The value for the given field, if it can be converted to the expected type T
     */

    public func from<T: Convertible>(field: String) throws -> T where T == T.ConvertedType {
        return try self.from(field:field, transformation: T.from)
    }

    /**
     Get an array of Convertible values from a field in the source data

     This transparently converts your types that conform to Convertible to an array on the Mappable type

     - parameter field: The field to retrieve from the source data, can be an empty string to return the
                        entire data set

     - throws: MapperError.MissingFieldError if the field doesn't exist
     - throws: MapperError.TypeMismatchError if the field exists but isn't an array of Any
     - throws: Any error produced by the subsequent Convertible implementations

     - returns: The value for the given field, if it can be converted to the expected type [T]
     */

    public func from<T: Convertible>(field: String) throws -> [T] where T == T.ConvertedType {
        let value = try self.JSONFrom(field:field)
        if let JSON = value as? [Any] {
            return try JSON.map(T.from)
        }

        throw MapperError.typeMismatchError(field: field, value: value, type: [Any].self)
    }

    /**
     Get a Convertible value from a field in the source data

     This transparently converts your types that conform to Convertible to properties on the Mappable type

     - parameter field: The field to retrieve from the source data, can be an empty string to return the
                        entire data set

     - returns: The value for the given field, if it can be converted to the expected type T otherwise nil
     */

    public func from<T: Convertible>(field: String) -> T? where T == T.ConvertedType {
        return try? self.from(field:field, transformation: T.from)
    }

    /**
     Get an optional array of Convertible values from a field in the source data

     This transparently converts your types that conform to Convertible to an array on the Mappable type

     - parameter field: The field to retrieve from the source data, can be an empty string to return the
                        entire data set

     - returns: The value for the given field, if it can be converted to the expected type [T]
     */

    public func from<T: Convertible>(field: String) -> [T]? where T == T.ConvertedType {
        return try? self.from(field:field)
    }

    /**
     Get a dictionary of Convertible values from a field in the source data

     This transparently converts a source dictionary to a dictionary of 2 Convertible types

     - parameter field: The field to retrieve from the source data, can be an empty string to return the
                        entire data set

     - throws: MapperError.TypeMismatchError if the value for the given field isn't a NSDictionary
     - throws: Any error produced by the Convertible implementation of either expected type

     - returns: A dictionary where the keys and values are created using their convertible implementations
     */

    public func from<U: Convertible, T: Convertible>(field: String) throws -> [U: T]
        where U == U.ConvertedType, T == T.ConvertedType
    {
        let object = try self.JSONFrom(field:field)
        guard let data = object as? NSDictionary else {
            throw MapperError.typeMismatchError(field: field, value: object, type: NSDictionary.self)
        }

        var result = [U: T]()
        for (key, value) in data {
            result[try U.from(value:key)] = try T.from(value:value)
        }

        return result
    }

    /**
     Get an optional dictionary of Convertible values from a field in the source data

     This transparently converts a source dictionary to a dictionary of 2 Convertible types

     - parameter field: The field to retrieve from the source data, can be an empty string to return the
                        entire data set

     - returns: A dictionary where the keys and values are created using their convertible implementations or
                nil if anything throws
     */

    public func from<U: Convertible, T: Convertible>(field: String) -> [U: T]?
        where U == U.ConvertedType, T == T.ConvertedType
    {
        return try? self.from(field:field)
    }

    /**
     Get an optional value from the given fields and source data. This returns the first non-nil value
     produced in order based on the array of fields

     - parameter fields: The array of fields to check from the source data.

     - returns: The first non-nil value to be produced from the array of fields, or nil if none exist
     */

    public func from<T: Convertible>(fields: [String]) -> T? where T == T.ConvertedType {
        for field in fields {
            if let value: T = try? self.from(field:field) {
                return value
            }
        }

        return nil
    }

    /**
     Get a Date from the given field in the source data

     - parameter field: The field to retrieve from the source data
     - parameter format: A string to pass to format the date
     - throws: MapperError.missingFieldError  if the field doesn't exist
     - throws: MapperError.convertibleError if field is not a string or doesn't match the format
     initializer fails with the passed rawValue

     - returns: The date for the given field
     */
    public func from(field: String, format: String) throws -> Date {
        let value = try self.JSONFrom(field:field)
        return try Date.from(value: value, format: format)
    }

    /**
     Get a Date from the given field in the source data

     - parameter field: The field to retrieve from the source data
     - parameter format: A string to pass to format the date
     initializer fails with the passed rawValue

     - returns: The date for the given field, or nil if field is not a string or doesn't match the format
     */
    public func from(field: String, format: String) -> Date? {
        return try? self.from(field: field, format: format)
    }

    // MARK: - Custom Transformation

    /**
     Get a typed value from the given field by using the given transformation

     - parameter field:          The field to retrieve from the source data, can be an empty string to return
                                 the entire data set
     - parameter transformation: The transformation function used to create the expected value

     - throws: MapperError.MissingFieldError if the field doesn't exist
     - throws: Any exception thrown by the transformation function, if you're implementing the transformation
               function you should use `MapperError`, see the documentation there for more info

     - returns: The value of type T for the given field
     */

    public func from<T>(field: String, transformation: (Any?) throws -> T) throws -> T {
        return try transformation(try self.JSONFrom(field:field))
    }

    /**
     Get an optional typed value from the given field by using the given transformation

     - parameter field:          The field to retrieve from the source data, can be an empty string to return
                                 the entire data set
     - parameter transformation: The transformation function used to create the expected value

     - returns: The value of type T for the given field, if the transformation function doesn't throw
                otherwise nil
     */

    public func optionalFrom<T>(field: String, transformation: (Any?) throws -> T?) -> T? {
        return (try? transformation(try? self.JSONFrom(field:field))).flatMap { $0 }
    }

    // MARK: - Private

    /**
     Get the object for a given field. If an empty string is passed, return the entire data source. This
     allows users to create objects from multiple fields in the top level of the data source

     - parameter field: The field to extract from the data source, can be an empty string to return the entire
                        data source

     - throws: MapperError.MissingFieldError if the field doesn't exist

     - returns: The object for the given field
     */
    fileprivate func JSONFrom(field: String) throws -> Any {
        if let value = field.isEmpty ? self.JSON : self.JSON.safeValueWith(keyPath:field) {
            return value
        }

        throw MapperError.missingFieldError(field: field)
    }
}
