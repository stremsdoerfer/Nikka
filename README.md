# StreemNetworking
StreemNetworking is a super simple Swift HTTP networking library that comes with many modules

- [Installation](#installation)
- [Usage](#usage)
- [Modules](#modules)

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
...

//This will send a POST request to the endpoint https://my-website.com/api/login with a json body `{"email":"foo@gmail.com","password":"bar"}``
MyProvider().request(Route(path:"/me/friends")).responseJSON { (response:Response<Any>) in
    //Parse here the object as an array or dictionary            
}
```

What is great with StreemNetworking, is that it's highly scalable, and modular. So you are able to define your endpoints wherever you want.
Here is a nice way of presenting your endpoints and using them:

```swift
//Endpoints relative to the user
extension Route {
    static let me       = Route(path:"/me", method: .get}
    static let friends  = Route(path:"/me/friends") //GET is the default method when it is not specified
    static let user     = {(id:String) in Route(path:"/user/\(id)")} //You can pass parameters by defining a closure that will return a Route
    static let login    = {(email:String, password:String) in Route(path:"/login", method:.post, params:["email":email, "password":password])}
}

...

//Then you can simply send a request by passing the route you defined above.
//This will send a POST request to the endpoint https://my-website.com/api/login with a json body `{"email":"foo@gmail.com","password":"bar"}``
MyProvider().request(.login("foo@gmail.com", "bar")).responseJSON { (response:Response<Any>) in
    //Parse here the object as an array or dictionary            
}
```

## Routes

`Route` is the object that allows you to define an endpoint and how you should talk to it. It requires at least a path that defines where the request is sent.
`GET` is the default method used.
You can pass parameters and headers to be sent with the request. And finally you can define how the parameters should be encoded.

### Examples

Here are a few examples of valid routes:

```swift
Route(path:"/me") //GET request to the relative path /me without any headers or parameters
Route(path:"/login", method:.post, params:["email":"example@gmail.com", "password":"qwerty12345"]) //POST request that use the default JSON encoding and will pass the the parameters in the request body.
Route(path:"/user/about", method:.put, params:["text":"Hey!!"], headers:["Authorization":"12345"], encoding:.form) //PUT request that sends its parameters using the form encoding
```

StreemNetworking currently supports 3 types of encoding, which are `json`, `form`, and `url`.

- `json` will encode your parameters in JSON and put them in the request body
- `form` will encode your parameters as query parameters and put them in the request body
- `url` will encode your parameters as query parameters and append them to the URL

### Multipart

A Route is also able to have a multipart form. Here's a simple way to upload a multipart image:


```swift
//First you define the Route that will take the image in parameter put it into a Multipart form
extension Route{
    static let uploadImage = {(image:UIImage) -> Route in
        var form = MultipartForm()
        form.append(data: UIImageJPEGRepresentation(image, 0.9)!, forKey: "image", fileName: "image.jpg")
        return Route(path:"/profile/picture", method:.post, multipartForm:form)
    }
}

...

//Then you just use the route as usual to send the request
let image = UIImage(named:"DSC_0025.JPG")!
MyProvider().request(.uploadImage(image)).uploadProgress { (sent, total) in
    print("upload progress: \(sent)/\(total)")
}.responseJSON { (json) in
    print("json: \(json)")
}
```


## Provider

The Provider can be highly customized if you want for instance to add default parameters to every request or validate every response the same way.

### Additional parameters and headers
```swift
class MyProvider:HTTPProvider {
    var baseURL = URL(string:"https://my-website.com/api")!
    var additionalHeaders = ["Locale":"en-US"]
    var additionalParameters = ["token":"d71106a0-dd44-4092-a72e"]
}
```

### Validating a response
API have a lot of different ways of handling errors. Some will just return an HTTP error code, some will have description with that error, some might also always return HTTP 200 and give customized errors.
You can define a specific behavior for your provider in order to define a failure and a success.

Let's take for instance the Deezer API, that returns a HTTP code 200 when it cannot find a song with a given ID.

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
    var description:String
    var code:Int

    init(code:Int, description:String) {
        self.code = code
        self.description = description
    }

    public static func ==(lhs: DeezerError, rhs: DeezerError) -> Bool {
        return lhs.code == rhs.code
    }
}
```

Then when declaring your provider, you can implement the `validate` method, that will be called when a response is received

```swift
class DeezerProvider:HTTPProvider {
    var baseURL = URL(string:"https://api.deezer.com")!

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

In some cases, it doesn't make sense to define a provider because you already have a full URL. You can use the Default Provider for that extent. It allows you to send a request by passing a route object with its full path.

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


## Modules
StreemNetworking works very well with JSON, it currently supports the libraries below to parse your data.

- [Gloss](https://github.com/hkellaway/Gloss) - [documentation](Sources/Gloss/README.md)
- [ModelMapper](https://github.com/lyft/mapper) - [documentation](Sources/ModelMapper/README.md)
- [ObjectMapper](https://github.com/Hearst-DD/ObjectMapper) - [documentation](Sources/ObjectMapper/README.md)
- [StreemMapper](https://github.com/JustaLab/mapper) - [documentation](Sources/StreemMapper/README.md)
- [Unbox](https://github.com/JohnSundell/Unbox) - [documentation](Sources/Unbox/README.md)

By using one of those modules, you'll be able to send a request and get your object right away:
```swift
MyProvider().request(Route(path:"/user/1234")).responseObject { (response:Response<User>) in
    //You can get the user like this:
    let user = response.result.value //This is a User?

    //Or you can switch on the response result if you want to manage an error case
    switch response.result{
    case .success(let user):
        print("success: user name is \(user.lastName)")
    case .failure(let error):
        print("error: \(error)") //Will print an error, if the User cannot be parsed for instance.
    }
}
```

Additionally StreemNetworking supports [Futures](https://en.wikipedia.org/wiki/Futures_and_promises) and [RxSwift](https://github.com/ReactiveX/RxSwift) with modules that can be used with CocoaPods by adding this to your PodFile:

```ruby
pod "StreemNetworking/Futures"
pod "StreemNetworking/Rx"
```

Note that when importing a module, the core and dependencies are automatically imported as well.


### Futures

Futures come very handy in modern programming, it allows you to chain your requests neatly. The Futures module allows you to return a future when you send a request.

I would encourage you to use the Future module along with a JSON library mentioned above. It is more powerful. However if for some reason you you like to get a Future with a JSON object or with the data return by the request. You could do the following:

```swift
//With Data and HTTPURLResponse
let loginDataFuture:Future<(HTTPURLResponse,Data)> = myProvider.request(.login("foo@gmail.com", "bar")).response()
loginDataFuture.onComplete { (result:Result<Any>) in
    switch result{
    case .success(let json):
        print("json: \(json)")
    case .failure(let error):
        print("error: \(error)")
    }
}

//With JSON
let loginJSONFuture:Future<Any> = myProvider.request(.login("foo@gmail.com", "bar")).responseJSON()
loginJSONFuture.onComplete { (result:Result<(HTTPURLResponse, Data)>) in
    expectation.fulfill()
    switch result{
    case .success(let response, let data):
        print("response code was: \(response.statusCode)")
    case .failure(let error):
        print("error: \(error)")
    }
}
```

### RxSwift

Even better, the Rx module. Similarly to the Future module, it will return Rx Observable that can be chained.

I would encourage you to use the Rx module along with a JSON library mentioned above. It is more powerful. However if for some reason you you like to get a Observable with a JSON object or with the data return by the request. You could do the following:

```swift
//With Data and HTTPURLResponse
let loginDataObservable:Observable<(HTTPURLResponse,Data)> = myProvider.request(.login("foo@gmail.com", "bar")).response()
loginDataObservable.subscribe(onNext: { (response:(HTTPURLResponse, Data)) in
    print("response code was: \(response.0.statusCode)")
}).addDisposableTo(bag)

//With JSON
let loginJSONObservable:Observable<Any> = myProvider.request(.login("foo@gmail.com", "bar")).responseJSON()
loginJSONObservable.subscribe(onNext: { json in
    print("json is: \(json)")
}).addDisposableTo(bag)
```


## Contributing

Contributions are more than welcome. Feel free to submit a pull request to add a new feature or to add support for your favorite JSON library.


## License

StreemNetworking is maintained by Emilien Stremsdoerfer and released under the Apache 2.0 license. See LICENSE for details
