import Foundation

precedencegroup ParsingPrecedence {
    associativity: left
    higherThan: NilCoalescingPrecedence
}
infix operator |> : ParsingPrecedence

// MARK: - RawRepresentable

public func |> <T: RawRepresentable>(map: Mapper, key: String) throws -> T {
    return try map.from(field:key)
}

public func |> <T: RawRepresentable>(map: Mapper, key: String) -> T? {
    return map.from(field:key)
}

public func |> <T: RawRepresentable>(map: Mapper, key: String) throws -> [T]
    where T.RawValue:Convertible, T.RawValue == T.RawValue.ConvertedType
{
    return try map.from(field:key)
}

public func |> <T: RawRepresentable>(map: Mapper, key: String) -> [T]?
    where T.RawValue:Convertible, T.RawValue == T.RawValue.ConvertedType
{
    return map.from(field:key)
}

// MARK: - Convertible

public func |> <T: Convertible>(map: Mapper, key: String) throws -> T where T == T.ConvertedType {
    return try map.from(field:key)
}

public func |> <T: Convertible>(map: Mapper, key: String) -> T? where T == T.ConvertedType {
    return map.from(field:key)
}

public func |> <T: Convertible>(map: Mapper, key: String) throws -> [T] where T == T.ConvertedType {
    return try map.from(field:key)
}

public func |> <T: Convertible>(map: Mapper, key: String) -> [T]? where T == T.ConvertedType {
    return map.from(field:key)
}

public func |> <U: Convertible, T: Convertible>(map: Mapper, key: String) -> [U:T]?
    where U == U.ConvertedType, T == T.ConvertedType
{
    return map.from(field:key)
}

public func |> <U: Convertible, T: Convertible>(map: Mapper, key: String) throws -> [U:T]
    where U == U.ConvertedType, T == T.ConvertedType
{
    return try map.from(field:key)
}

public func |> (map: Mapper, keyFormat: (String, String)) throws -> Date {
    return try map.from(field: keyFormat.0, format: keyFormat.1)
}

public func |> (map: Mapper, keyFormat: (String, String)) -> Date? {
    return map.from(field: keyFormat.0, format: keyFormat.1)
}

// MARK: - Mappable

public func |> <T: Mappable>(map: Mapper, key: String) throws -> T {
    return try map.from(field:key)
}

public func |> <T: Mappable>(map: Mapper, key: String) -> T? {
    return map.from(field:key)
}

public func |> <T: Mappable>(map: Mapper, key: String) throws -> [T] {
    return try map.from(field:key)
}

public func |> <T: Mappable>(map: Mapper, key: String) -> [T]? {
    return map.from(field:key)
}
