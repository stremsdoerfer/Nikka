# StreemNetworking
A simple Swift HTTP networking library that comes with many modules

- [Installation](#installation)
- [Modules](#modules)
- [Usage](#usage)

## Installation

###Requirements

- iOS 8.0+
- Xcode 8.0+
- Swift 3.0+

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

In 99% of the cases your app will need to talk to an API, that API has a behavior and you would like to map that behavior to your app. To handle errors correctly for instance.
StreemNetworking has been designed with this in mind. It allows you to define a common behavior for an API, by defining a `Provider`.
Here's a simple example of what it looks like:

```swift
import StreemNetworking

//Define your provider
class MyProvider:HTTPProvider {
    var baseURL = URL(string:"https://my-website.com/api")!
}

//Define your API endpoints
extension Route {
    static let me       = Route(path:"/me", method: .get}
    static let friends  = Route(path:"/me/friends", method: .get)
    static let user     = {(id:String) in Route(path:"/user/\(id)")}
    static let login    = {(email:String, password:String) in Route(path:"/login", method:.post, params:["email":email, "password":password])}
}

...

//Send a request
let myProvider = MyProvider()

myProvider.request(.login(email, password)).responseJSON { (response:Response<Any>) in
    //Parse here the object as an array or dictionary            
}
```

## Provider

The Provider can be highly customized if you want for instance to add default parameters to every request or validate every response the same way.

### Additional parameters and headers
```swift
class MyProvider:HTTPProvider {
    var baseURL:URL { return URL(string:"https://my-website.com/api")!}
    var additionalHeaders = ["Locale":"en-US"]
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
struct DeezerError : StreemError, Equatable{
    var domain: String
    var description:String
    var code:Int

    init(code:Int, description:String) {
        self.domain = "com.deezer.Deezer"
        self.code = code
        self.description = description
    }

    public static func ==(lhs: DeezerError, rhs: DeezerError) -> Bool {
        return lhs.code == rhs.code
    }
}
```

Then when declaring your provider, you can check the content of the response and send back an error

```swift
class DeezerProvider:HTTPProvider {
    var baseURL:URL { return URL(string:"https://api.deezer.com")!}

    func validate(response: HTTPURLResponse, data: Data, error: Error?) -> StreemError? {
        let jsonError = (try? JSONSerialization.jsonObject(with: data, options: .allowFragments)) as? [String:Any]
        if let error = json?["error"] as? [String:Any], let code = error["code"] as? Int, let desc = error["message"] as? String {
            return DeezerError(code:code, description:desc)
        }
        return nil
    }
}

```

Then when sending your request, if deezer returns a HTTP code 200 but with a json error in its body. It will go through the validator and send you back the error.

```swift
let myProvider = DeezerProvider()

myProvider.request(Route(path:"/track/313555658769").responseJSON { (response:Response<Any>) in
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
In some cases, it is useful to define a certain behavior when an error is encountered. For instance if you receive a HTTP 401 error you might want to terminate the user session. This can be done by implementing the `shouldContinue` method.

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

### Without Provider

In some cases, it doesn't make sense to define a provider because you have a full URL at your disposable. You can use the Default Provider for that extent. It allows you to send a request by passing a route object with its full path.

```swift
DefaultProvider.request(Route(path:"https://my-website.com/api/user/1")).responseJSON { (response:Response<Any>) in
    switch response.result{
    case .success(let json):
        print("json: \(json)")
    case .failure(let error):
        print("error: \(error)")
    }
}
```

## Route

`Route` is the object that allows you to define an endpoint and how you should talk to it. It requires at least a path that defines where the request is sent.
GET is the default method used.
You can pass parameters and headers to be sent with the request. And finally you can define how the parameters should be encoded.

Here are a few examples of valid routes:

```swift
Route(path:"/me")
Route(path:"/login", method:.post, params:["email":"example@gmail.com", "password":"qwerty12345"])
Route(path:"/user/about", method:.put, params:["text":"Hey!!"], headers:["Authorization":"12345"], encoding:.json)
```

StreemNetworking currently supports 3 types of encoding, which are `json`, `form`, and `url`.

- `json` will encode your parameters in JSON and put them in the request body
- `form` will encode your parameters as query parameters and put them in the request body
- `url` will encode your parameters as query parameters and append them to the URL



## Modules
StreemNetworking has many different modules that have been implemented, to make it even more easy to use StreemNetworking.

- [Futures]()
- [Mapper]()
- [MapperRx]()
- [MapperFutures]()
- [Rx]()

They can be added to your project independently with CocoaPods as following:
```ruby
pod "StreemNetworking/Mapper"
pod "StreemNetworking/MapperRx"
pod "StreemNetworking/MapperFutures"
pod "StreemNetworking/Futures"
pod "StreemNetworking/Rx"
```

Note that when importing a module, the core and dependencies are automatically imported as well.

### StreemMapper
[StreemMapper](https://github.com/JustaLab/mapper) is a really nice library that allows you to parse JSON very cleanly.

```swift
struct User:Mappable{
    let id:Int
    let name:String
    let pictureURL:URL?

    init(map: Mapper) throws {
        try id      = map |> "id"
        try name    = map |> "name"
        pictureURL  = map |> "picture_url"
    }
}
```

Then with StreemNetworking/Mapper module it becomes super easy to send a request and get the expected objects at the same time:

```swift
myProvider.request(.user(1234)).responseObject { (response:Response<User>) in
    switch response.result{
    case .success(let user):
        print("success: user name is \(user.lastName)")
    case .failure(let error):
        print("error: \(error)") //Will print an error, if the User cannot be parsed. (if the User initializer has thrown an error)
    }
}
```

Or if you want expect an array:
```swift
myProvider.request(.friends).responseArray { (response:Response<[User]>) in
    switch response.result{
    case .success(let users):
        print("success: got \(users.count) friends")
    case .failure(let error):
        print("error: \(error)") //Will print an error, if the json is not an array
    }
}
```


### Futures
Futures come very handy in modern programming, it allows you to chain your requests neatly. The Futures module allows you to return a future when you send a request.

Let's say for example that you want to log in and fetch a feed right away. It wouldn't really make sense to have an empty app if the user has logged in, so you want to be sure that both request succeed before doing anything else. This can be achieved quite simply with futures:

```swift
let userFuture:Future<User> = myProvider.request(.login(email, password)).responseObject()
let feedFuture:Future<Feed> = userFuture.flatMap {self.myProvider.request(.feed($0.id)).responseObject()}

feedFuture.onComplete { (result:Result<Feed>) in
    switch result{
    case .success(let feed):
        print("logged in successfully, and feed retrieved")
    case .failure(let error):
        print("an error occurred on the way")
    }
}
```

This example has been written with the `StreemMapperFutures` module that also takes the advantages of `StreemMapper`. The `Futures` modules can also be used but it is only able to return JSON and Data objects.


### Rx

Even better, the Rx module. Similarly to the Future module, it will return Rx Observable that can be chained.
Let's say, in this example, that you want to login with facebook. You'll probably make a call to facebook to get a token and then use that token to login into your app.
Let's say that you've implemented a facebook login function that returns an Observable.
You can then chain this observable with your own requests and vice versa.

```swift
let facebookTokenObs:Observable<String> =  FBSDKLoginManager().logIn(with: ["email"], from: self)
let userObs:Observable<User> = facebookTokenObs.flatMap {self.myProvider.request(.me($0)).responseObject()}

userObs.subscribe(onNext: { (user:User) in
  //Do something with the user
}, onError:{ (error:Error) in
  //Display an error message
}).addDisposableTo(disposeBag)
```
