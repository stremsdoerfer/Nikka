//
//  MultipartForm.swift
//  Nikka
//
//  Created by Emilien on 10/22/16.
//  Copyright © 2016 Emilien Stremsdoerfer. All rights reserved.
//

import Foundation

public struct MultipartForm {

    let boundary = "Boundary-\(UUID().uuidString)"

    private var parameters = [String: Any]()

    private var dataParameters = [(String, Data, String, String)]()

    public init() {}

    public mutating func append(value: String, forKey key: String) {
        parameters[key] = value
    }

    public mutating func append(data: Data, forKey key: String, fileName: String, mimeType: String="application/octet-stream") {
        dataParameters.append((key, data, fileName, mimeType))
    }

    public func encode() throws -> Data {
        var data = Data()

        try parameters.forEach { (param: (String, Any)) in
            try data.append("--\(boundary)\r\n".safeData())
            try data.append("Content-Disposition: form-data; name=\"\(param.0)\"\r\n\r\n".safeData())
            try data.append("\(param.1)\r\n".safeData())
        }

        //swiftlint:disable:next large_tuple
        try dataParameters.forEach { (param: (String, Data, String, String)) in
            try data.append("--\(boundary)\r\n".safeData())
            try data.append("Content-Disposition: form-data; name=\"\(param.0)\"; filename=\"\(param.2)\"\r\n".safeData())
            try data.append("Content-Type: \(param.3)\r\n\r\n".safeData())
            data.append(param.1)
            try data.append("\r\n".safeData())
        }
        try data.append("--\(boundary)--\r\n".safeData())

        return data
    }
}

extension String {

    func safeData(using encoding: String.Encoding = .utf8) throws -> Data {
        guard let data = self.data(using: encoding) else {
            throw NikkaNetworkingError.parameterEncoding(self)
        }
        return data
    }

}
