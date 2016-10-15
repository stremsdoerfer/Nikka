# StreemNetworking
A simple networking library for Swift that comes with many modules


## Installation

#### With [CocoaPods](http://cocoapods.org/)

```ruby
use_frameworks!

pod "StreemNetworking"
```

#### With [Carthage](https://github.com/Carthage/Carthage)

```
github "JustaLab/StreemNetworking"
```

## Usage

### Simple example:

```swift
import StreemNetworking

//Define your provider
class MyProvider:HTTPProvider {
    var baseURL:URL { return URL(string:"https://my-website.com/api")!}
}

//Define your API endpoints
extension Route {
    static let Me       = Route(path:"/me", method: .get}
    static let Friends  = Route(path:"/me/friends", method: .get)
    static let User     = {(id:String) in Route(path:"/me/game/\(id)")}
    static let Login    = {(email:String, password:String) in Route(path:"/login", method:.post, params:["email":email, "password":password])}
}


//Send a request
let myProvider = MyProvider()

myProvider.request(.Login(email, password)).responseJSON { (response:Response<Any>) in
    //Parse here the object as an array or dictionary            
}

```

## Customizing provider

Provider can be highly customized if you want for instance to add default parameters to every request or validate every response the same way.

### Default headers
```swift
class MyProvider:HTTPProvider {
    var baseURL:URL { return URL(string:"https://my-website.com/api")!}
    var defaultHeaders = ["Locale":"en-US"]
}
```

### Additional parameters
```swift
class MyProvider:HTTPProvider {
    var baseURL:URL { return URL(string:"https://my-website.com/api")!}
    var additionalParameters = ["token":"d71106a0-dd44-4092-a72e"]
}
```

### Validating a response
API have a lot of different ways of handling errors. Some will just return an HTTP error code, some will have description with that error, some might also always return HTTP 200 and give customized errors.
You can define a specific behavior for your provider in order to define a failure and a success.

Let's take for instance the Deezer API, who chooses to return HTTP code 200 when it cannot find a song with a given ID

https://api.deezer.com/track/313555658769 will return:
```json
{
"error": {
  "type":"DataException",
  "message":"no data",
  "code":800
  }
}
```

You should first define your own error that conforms to the StreemError protocol:
```swift
struct DeezerError : StreemError{
    var domain: String { get { return "com.deezer.Deezer" } }
    var description:String
    var code:Int
    
    init(code:Int, description:String) {
        self.code = code
        self.description = description
    }
}
```

Then when declaring your provider, you can check the content of the response and send back an error

```swift
class MyProvider:HTTPProvider {
    var baseURL:URL { return URL(string:"https://my-website.com/api")!}
    
    func validate(response: HTTPURLResponse, data: Data, error: Error?) -> StreemError? {
        let jsonError = //
        if let error = json?["error"] as? [String:Any], let code = error["code"] as? Int, let desc = error["message"] as? String {
            return DeezerError(code:code, description:desc)
        }
        return nil
    }
}
```

Then in your code you'll get

```swift
let myProvider = MyProvider()

myProvider.request(.Login(email, password)).responseJSON { (response:Response<Any>) in
    switch response.result{
       case .success(let value):
           print("success")
       case .failure(let error):
           print("error: \(error.description)")
    }
}

//This will print "error: no data"
```

### Stopping on error
In some cases, it is useful to define a certain behavior when an error is encountered. For instance if you receive a HTTP 401 error you might want to terminate the user session

```swift
class MyProvider:HTTPProvider {
    var baseURL:URL { return URL(string:"https://my-website.com/api")!}
    
    func shouldContinue(with error: StreemError) -> Bool {
        if let err = error as? StreemNetworkingError , err == StreemNetworkingError.http(401){
            print("should log out")
            return false
        }
        return true
    }
}
```
