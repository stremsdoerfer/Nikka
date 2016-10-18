//
//  MockProviders.swift
//  StreemNetworking
//
//  Created by Emilien on 10/15/16.
//  Copyright © 2016 Emilien Stremsdoerfer. All rights reserved.
//

@testable import StreemNetworking


class TestProvider:HTTPProvider{
    var baseURL: URL { get { return URL(string: "https://httpbin.org")! }}
}

class TestHeadersProvider:HTTPProvider{
    var baseURL: URL { get { return URL(string: "https://httpbin.org/")! }}
    var additionalHeaders: [String : String] = ["TestHeader":"TestHeaderValue"]
}

class TestParamsProvider:HTTPProvider{
    var baseURL: URL { get { return URL(string: "https://httpbin.org/")! }}
    var additionalParams: [String : Any] = ["token":12345]
}

class TestProviderValidateAllHTTPCode:HTTPProvider{
    var baseURL: URL { get { return URL(string: "https://httpbin.org/")! }}
    
    func validate(response: HTTPURLResponse?, data: Data, error: Error?) -> StreemError? {
        return nil
    }
}

class TestProviderDeezer:HTTPProvider{
    var baseURL: URL { get { return URL(string: "https://api.deezer.com/")! }}
    
    func validate(response: HTTPURLResponse?, data: Data, error: Error?) -> StreemError? {
        let json = (try? JSONSerialization.jsonObject(with: data, options: .allowFragments)) as? [String:Any]
        
        if let error = json?["error"] as? [String:Any], let code = error["code"] as? Int, let desc = error["message"] as? String {
            return DeezerError(code:code, description:desc)
        }
        return nil
    }
}

struct DeezerError : StreemError, Equatable{

    public static func ==(lhs: DeezerError, rhs: DeezerError) -> Bool {
        return lhs.code == rhs.code
    }

    var domain: String
    var description:String
    var code:Int
    
    init(code:Int, description:String) {
        self.code = code
        self.domain = "com.deezer.Deezer"
        self.description = description
    }
}
