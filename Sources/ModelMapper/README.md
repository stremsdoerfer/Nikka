# ModelMapper + StreemNetworking

ModelMapper + StreemNetworking is a extension of the StreemNetworking library that allows you to get plain object directly from a request by parsing the JSON with the [ModelMapper](https://github.com/lyft/mapper) library

## Installation

To install this extension with CocoaPods simply add this line to your podfile:

```ruby
pod 'StreemNetworking/ModelMapper'
```

If you want to use RxSwift or Futures in addition to the ModelMapper library, you should replace the above line by one of the following:
```ruby
pod 'StreemNetworking/ModelMapperRx'
pod 'StreemNetworking/ModelMapperFutures'
```

## Usage
With [ModelMapper](https://github.com/lyft/mapper)   you would have structure like this:

```swift
struct User:Mappable{
    let id:Int
    let name:String

    init(map: Mapper) throws {
        self.id = try map.from("id")
        self.name = try map.from("name")
    }
}
```

Then with StreemNetworking/ModelMapper module it becomes super easy to send a request and get the expected objects at the same time:

```swift
myProvider.request(Route(path:"/user/1234")).responseObject { (response:Response<User>) in
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
myProvider.request(Route(path:"/friends")).responseArray { (response:Response<[User]>) in
    switch response.result{
    case .success(let users):
        print("success: got \(users.count) friends")
    case .failure(let error):
        print("error: \(error)") //Will print an error, if the json is not an array
    }
}
```

## Futures
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

## Rx

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
