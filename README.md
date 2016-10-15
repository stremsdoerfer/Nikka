# StreemNetworking
A simple networking library for Swift that comes with many modules

- [Installation](#installation)
- [Modules](#modules)
- [Usage](#usage)

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
    static let me       = Route(path:"/me", method: .get}
    static let friends  = Route(path:"/me/friends", method: .get)
    static let user     = {(id:String) in Route(path:"/user/\(id)")}
    static let login    = {(email:String, password:String) in Route(path:"/login", method:.post, params:["email":email, "password":password])}
}


//Send a request
let myProvider = MyProvider()

myProvider.request(.login(email, password)).responseJSON { (response:Response<Any>) in
    //Parse here the object as an array or dictionary            
}

```

## Modules
StreemNetworking has many differenr modules that has been implemented to ease a bit more the use of it. Modules can be installed with CocoaPods 
```ruby
pod "StreemNetworking/Mapper"
pod "StreemNetworking/Futures"
pod "StreemNetworking/Rx"
```

### Mapper
Mapper is a library forked from lyft that allows us to parse JSON very cleanly.

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

Then with StreemNetworking/Mapper module it becomes really easy to send a request and get the expected objects at the same time:

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
Futures come very handy in modern programming, it allows you to chain your requests neatly. The StreemNetworking/Futures module allows you to return a future when you send a request. It relies currently on Mapper to parse the objects.

Let's say for example that you want to log in and fetch a feed right away. It wouldn't really make sense to have an empty app if the user has logged in, so you want to be sure that both request succeed before doing anything else. This can be achieved quite simply with futures:

```swift
let userFuture:Future<User> = myProvider.request(.login(email, password)).response()
let feedFuture:Future<Future> = userFuture.flatMap {self.myProvider.request(.feed($0.id)).response()}
        
feedFuture.onComplete { (result:Result<Feed>) in
    switch result{
    case .success(let feed):
        print("logged in successfully, and feed retrieved")
    case .failure(let error):
        print("an error occurred on the way")
    }
}
```


### Rx

The Rx module is quite similar to the Future module, it will return Rx Observable that can be chained. 
Let's say, in this example, that you want to login with facebook. You'll probably make a call to facebook to get a token and then use that token to login into your app. 
You should proabably implement a facebook login function that returns a Observable. Something like this:

```swift
extension FBSDKLoginManager {
    func logIn(with readPermissions:[Any]!, from viewController:UIViewController!) -> Observable<String> {
        return Observable.create{ observer in
            self.logIn(withReadPermissions: readPermissions, from: viewController) { (result:FBSDKLoginManagerLoginResult?, error:Error?) in
                if let token = result?.token.tokenString{
                    observer.onNext(token)
                }else{
                    observer.onError(error ?? WkmGlobalError.facebookLoginCancelled)
                }
                observer.on(.completed)
            }
            return Disposables.create()
        }
    }
}
```

Then you are able to chain this observable with your own requests and vice versa.

```swift
let facebookTokenObs:Observable<String> =  FBSDKLoginManager().logIn(with: ["email"], from: self)
let userObs:Observable<User> = facebookTokenObs.flatMap {self.myProvider.request(.me($0)).response()}
        
userObs.subscribe(onNext: { (user:User) in
    //Do something with the user
}).addDisposableTo(disposeBag)
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
    var domain: String
    var description:String
    var code:Int
    
    init(code:Int, description:String) {
        self.domain = "com.deezer.Deezer"
        self.code = code
        self.description = description
    }
}
```

Then when declaring your provider, you can check the content of the response and send back an error

```swift
class MyProvider:HTTPProvider {
    var baseURL:URL { return URL(string:"https://api.deezer.com")!}
    
    func validate(response: HTTPURLResponse, data: Data, error: Error?) -> StreemError? {
        let jsonError = (try? JSONSerialization.jsonObject(with: data, options: .allowFragments)) as? [String:Any]
        if let error = json?["error"] as? [String:Any], let code = error["code"] as? Int, let desc = error["message"] as? String {
            return DeezerError(code:code, description:desc)
        }
        return nil
    }
}

extension Route{
    static let track = {(id:Int64) in Route(path:"/track/\(id)")}
}
```

Then in your code you'll get

```swift
let myProvider = MyProvider()

myProvider.request(.track(313555658769)).responseJSON { (response:Response<Any>) in
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
In some cases, it is useful to define a certain behavior when an error is encountered. For instance if you receive a HTTP 401 error you might want to terminate the user session. This can be done by overriding the `shouldContinue` method.

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
