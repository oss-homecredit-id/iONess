# iONess

iONess (iOS Network Session) is HTTP Request Helper for the iOS platform used by Home Credit Indonesia iOS App. It using [Ergo](https://github.com/nayanda1/Ergo) as a concurrent helper and promise pipelining.

![build](https://github.com/oss-homecredit-id/iONess/workflows/build/badge.svg)
![test](https://github.com/oss-homecredit-id/iONess/workflows/test/badge.svg)
[![SwiftPM Compatible](https://img.shields.io/badge/SwiftPM-Compatible-brightgreen)](https://swift.org/package-manager/)
[![Version](https://img.shields.io/cocoapods/v/iONess.svg?style=flat)](https://cocoapods.org/pods/iONess)
[![License](https://img.shields.io/cocoapods/l/iONess.svg?style=flat)](https://cocoapods.org/pods/iONess)
[![Platform](https://img.shields.io/cocoapods/p/iONess.svg?style=flat)](https://cocoapods.org/pods/iONess)

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

- Swift 5.0 or higher (or 5.1 when using Swift Package Manager)
- iOS 10 or higher (latest version)
- iOS 8 or higher (1.0.0 until 1.2.5 version)

### Only Swift Package Manager

- macOS 10.10 or higher
- tvOS 10 or higher

## Installation

### Cocoapods

iONess is available through [CocoaPods](https://cocoapods.org). To install it, simply add the following line to your Podfile:

```ruby
pod 'iONess', '~> 2.0.0'
```

or for iOS 8 or lower

```ruby
pod 'iONess', '~> 1.2.0'
```

### Swift Package Manager from XCode

- Add it using xcode menu **File > Swift Package > Add Package Dependency**
- Add **https://github.com/oss-homecredit-id/iONess.git** as Swift Package url
- Set rules at **version**, with **Up to Next Major** option and put **2.0.0** as its version or **1.2.0** for iOS 8 or lower
- Click next and wait

### Swift Package Manager from Package.swift

Add as your target dependency in **Package.swift**. Use **2.0.0** as its version or **1.2.0** for iOS 8 or lower

```swift
dependencies: [
  .package(url: "https://github.com/oss-homecredit-id/iONess.git", .upToNextMajor(from: "2.0.0"))
]
```

Use it in your target as `iONess`

```swift
 .target(
  name: "MyModule",
  dependencies: ["iONess"]
)
```

## Contributor

- Home Credit Indonesia, iOS Teams
- nayanda, nayanda1@outlook.com

## License

iONess is available under the MIT license. See the LICENSE file for more info.

## Usage Example

### Basic Usage

`iONess` is designed to simplify the request process for HTTP Request. All you need to do is just create the request using `Ness` / `NetworkSessionManager` class:

```swift
Ness.default
  .httpRequest(.get, withUrl: "https://myurl.com")
  .dataRequest()
  .then { result in
    // do something with result this will not executed when request failed
  }
```

or with no completion at all:

```swift
Ness.default
  .httpRequest(.get, withUrl: "https://myurl.com")
  .dataRequest()
```

When data `dataRequest()` is called, it will always execute the request right away no matter it have completion or not.
`dataRequest()` actually returning `Promise` object from [Ergo](https://github.com/nayanda1/Ergo) so you could always do everything you can do with `Ergo Promise`:

```swift
Ness.default
  .httpRequest(.get, withUrl: "https://myurl.com")
  .dataRequest()
  .then { result in
    // do something with result this will not executed when request failed
  }.handle { error in
    // do something if error occurs
  }.finally { result, error in
    // do something regarding of error or not after request completed
  }
```

You could always check [Ergo here](https://github.com/nayanda1/Ergo) about what its promise can do.

### Create Request

To create request you can do something like this:

```swift
Ness.default.httpRequest(.get, withUrl: "https://myurl.com")
  .set(urlParameters: ["param1": "value1", "param2": "value2"])
  .set(headers: ["Authorization": myToken])
  .set(body: dataBody)
  ..
  ..
```
or with customize `URLSession`:

```swift
// create session
var session = URLSession()
session.configuration = myCustomConfig
session.delegateQueue = myOperationQueue
..
..

// create Ness instance
let ness = Ness(with: session)

// create request
ness.httpRequest(.get, withUrl: "https://myurl.com")
  .set(urlParameters: ["param1": "value1", "param2": "value2"])
  .set(headers: ["Authorization": myToken])
  .set(body: dataBody)
  ..
  ..
```

it's better to save the instance of Ness and reused it since it will be just creating the request with the same `URLSession` unless you want to use any other `URLSession` for another request.

available enumeration for HTTP Method to use are: 
- `post`
- `get`
- `put`
- `patch`
- `delete`
- `head`
- `connect`
- `options`
- `trace`
- `none` if you don't want to include HTTP Method header
- `custom(String)`

to set custom type of body, you need to pass those custom type encoder which implement `HTTPBodyEncoder` object to encode the object into the data:

```swift
Ness.default.httpRequest(.get, withUrl: "https://myurl.com")
  .set(body: myObject, with encoder: myEndoder) -> Self
  ..
  ..
```

The declaration of `HTTPBodyEncoder` is:

```swift
public protocol HTTPBodyEncoder {
  var relatedHeaders: [String: String]? { get }
  func encoder(_ any: Any) throws -> Data
}
```
the `relatedHeaders` is the associated header with this encoding which will auto-assigned to the request headers. this variable is optional since the default implementation are returning nil

there some different default method to set the body with iONess default body encoder which are:
- `func set(body: Data) -> Self`
- `func set(stringBody: String, encoding: String.Encoding = .utf8) -> Self`
- `func set(jsonBody: [String: Any]) -> Self`
- `func set(arrayJsonBody: [Any]) -> Self`
- `func set<EObject: Encodable>(jsonEncodable: EObject) -> Self`
- `func set<EObject: Encodable>(arrayJsonEncodable: [EObject]) -> Self`

After the request is ready then prepare the request which will return Thenable:

```swift
Ness.default.httpRequest(.get, withUrl: "https://myurl.com")
  .set(urlParameters: ["param1": "value1", "param2": "value2"])
  .set(headers: ["Authorization": myToken])
  .set(body: dataBody)
  ..
  ..
  .dataRequest()
```
or for download, you need to give target location `URL` where you want to downloaded data to be saved:

```swift
Ness.default.httpRequest(.get, withUrl: "https://myurl.com")
  .set(urlParameters: ["param1": "value1", "param2": "value2"])
  .set(headers: ["Authorization": myToken])
  .set(body: dataBody)
  ..
  ..
  .downloadRequest(forSavedLocation: myTargetUrl)
```

or for updload you need to give file location `URL` which you want to upload:

```swift
Ness.default.httpRequest(.get, withUrl: "https://myurl.com")
  .set(urlParameters: ["param1": "value1", "param2": "value2"])
  .set(headers: ["Authorization": myToken])
  .set(body: dataBody)
  ..
  ..
  .uploadRequest(forFileLocation: myTargetUrl)
```

### Data Request Promise

After creating data request, you can just execute the request with then method:

```swift
Ness.default
  .httpRequest(.get, withUrl: "https://myurl.com")
  ..
  ..
  .dataRequest()
  .then { result in
  // do something with result
}
```

The result is the `URLResult` object which contains:
- `urlResponse: URLResponse?` which is the original response which you can read the documentation at [here](https://developer.apple.com/documentation/foundation/httpurlresponse)
- `error: Error?` which is an error if happens. it will be nil on success response
- `responseData: Data?` which is raw data of the response body
- `isFailed: Bool` which is true if request is failed
- `isSucceed: Bool` which is true if the request is succeed
- `httpMessage: HTTPResultMessage?` which is the response message of the request. It Will be nil if the result is not an HTTP result

The `HTTPResultMessage` is the detailed HTTP response from the `URLResult`:
- `url: HTTPURLCompatible` which is the origin URL of the response
- `headers: Header` which is headers of the response
- `body: Data?` which is the body of the response
- `statusCode: Int` which is the status code of the response

You can get the promise object or ignore it. It will return `DataPromise` which contains the status of the request

```swift
let requestPromise = Ness.default
  .httpRequest(.get, withUrl: "https://myurl.com")
  ..
  ..
  .dataRequest()
let status = requestPromise.status
```

The statuses are:
- `running(Float)` which contains the percentage of request progress from 0 - 1
- `dropped`
- `idle`
- `completed(HTTPURLResponse)` which contains the completed response
- `error(Error)` which contains an error if there are occurs

you can cancel the request using `drop()` function:

```swift
requestPromise.drop()
```

since the promise is based on the [Ergo](https://github.com/nayanda1/Ergo) Promise, it contains the result of the request if it already finished and an error if the error occurs:

```swift
// will be nil if the request is not finished yet or if the error occurs
let result = requestPromise.result

// will be nil if an error did not occur or the request is not finished yet
let error = requestPromise.error

// will be true if request completed
print(requestPromise.isCompleted)
```

### Upload Request Promise

Upload requests are the same as Data requests in terms of `Promise`.

### Download Request Promise

Download requests have a slight difference from data requests or upload requests. The download request can be paused and resumed, and the result is different

The result is the `DownloadResult` object which contains:
- `urlResponse: URLResponse?` which is the original response which you can read the documentation at [here](https://developer.apple.com/documentation/foundation/httpurlresponse)
- `error: Error?` which is an error if happens. it will be nil on success response
- `dataLocalURL: URL?` which is the location of downloaded data
- `isFailed: Bool` which is true if request is failed
- `isSucceed: Bool` which is true if the request is succeed

You can pause the download and resume:

```swift
request.pause()

let resumeStatus = request.resume()
```
resume will return `ResumeStatus` which is enumeration:
- `resumed`
- `failToResume`

### Decode Response Body For Data Request

to parse the body, you can do: 

```swift
let decodedBody = try? result.message.parseBody(using: myDecoder)
```

the parseBody are accept any object that implement `ResponseDecoder`. The declaration of ResponseDecoder protocol is like this: 

```swift
public protocol ResponseDecoder {
  associatedtype Decoded
  func decode(from data: Data) throws -> Decoded
}
```

so you can do something like this: 

```swift
class MyResponseDecoder: ResponseDecoder {
  typealias Decoded = MyObject
   
  func decode(from data: Data) throws -> MyObject {
    // do something to decode data into MyObject
  }
}
```

there are default base decoder you can use if you don't want to parse from `Data`

```swift
class MyJSONResponseDecoder: BaseJSONDecoder<MyObject> {
  typealias Decoded = MyObject
   
  override func decode(from json: [String: Any]) throws -> MyObject {
    // do something to decode json into MyObject
  }
}

class MyStringResponseDecoder: BaseStringDecoder<MyObject> {
  typealias Decoded = MyObject
   
  override func decode(from string: String) throws -> MyObject {
    // do something to decode string into MyObject
  }
}
```

the `HTTPResultMessage` have default function to automatically parse the body which:
- `func parseBody(toStringEndcoded encoding: String.Encoding = .utf8) throws -> String`
- `func parseJSONBody() throws -> [String: Any]`
- `func parseArrayJSONBody() throws -> [Any]`
- `func parseJSONBody<DObject: Decodable>() throws -> DObject`
- `func parseArrayJSONBody<DObject: Decodable>() throws -> [DObject]`
- `func parseJSONBody<DOBject: Decodable>(forType type: DOBject.Type) throws -> DOBject`
- `func parseArrayJSONBody<DObject: Decodable>(forType type: DObject.Type) throws -> [DObject]`

### Validator

You can add validation for the response like this:

```swift
Ness.default
  .httpRequest(.get, withUrl: "https://myurl.com")
  ..
  ..
  .validate(statusCodes: 0..<300)
  .validate(shouldHaveHeaders: ["Content-Type": "application/json"])
  .dataRequest()
```
If the response is not valid, then it will have an error or be dispatched into `handle` closure with an error.

the provided validate method are:

- `validate(statusCode: Int) -> Self`
- `validate(statusCodes: Range<Int>) -> Self`
- `validate(shouldHaveHeaders headers: [String:String]) -> Self`
- `validate(_ validation: HeaderValidator.Validation, _ headers: [String: String]) -> Self`

You can add custom validator to validate the http response. The type of validator is `URLValidator`:

```swift
public protocol ResponseValidator {
  func validate(for response: URLResponse) -> ResponseValidatorResult
}
```

`ResponseValidatorResult` is a enumeration which contains:
- `valid`
- `invalid`
- `invalidWithReason(String)` invalid with custom reason which will be a description on `NetworkSessionError` Error

and put your custom `ResponseValidator` like this:

```swift
Ness.default
  .httpRequest(.get, withUrl: "https://myurl.com")
  ..
  ..
  .validate(using: MyCustomValidator())
  .dataRequest()
```

You can use `HTTPValidator` if you want to validate only `HTTPURLResponse` and automatically invalidate the other:

```swift
public protocol HTTPValidator: URLValidator {
  func validate(forHttp response: HTTPURLResponse) -> URLValidatorResult
}
```

Remember you can put as many validators as you want, which will validate the response using all those validators from the first until the end or until one validator returns `invalid`
If you don't provide any `URLValidator`, then it will be considered invalid if there's an error or no response from the server, otherwise, all the responses will be considered valid

### NetworkSessionManagerDelegate

You can manipulate request or action globally in Session level by using `NetworkSessionManagerDelegate`:

```swift
public protocol NetworkSessionManagerDelegate: class {
  func ness(_ manager: Ness, willRequest request: URLRequest) -> URLRequest
  func ness(_ manager: Ness, didRequest request: URLRequest) -> Void
}
```
both methods are optional. The methods will run and functional for:
- `ness(_: , willRequest: )` will run before any request executed. You can manipulate `URLRequest` object here and return it or doing anything before request and return the current `URLRequest`
- `ness(_: , didRequest: )` will run after any request is executed, but not after the request is finished.

### RetryControl

You can control when to retry if your request is failed using `RetryControl` protocol:

```swift
public protocol RetryControl {
  func shouldRetry(
    for request: URLRequest, 
    response: URLResponse?, 
    error: Error, 
    didHaveDecision: (RetryControlDecision) -> Void) -> Void
}
```

The method will run on a request failure. The only thing you need to do is passing the `RetryControlDecision` into `didHaveDecision` closure which is an enumeration with members:
- `noRetry` which will automatically fail the request
- `retryAfter(TimeInterval)` which will retry the same request after `TimeInterval`
- `retry` which will retry the same request immediately

You can assign `RetryControl` when preparing request:

```swift
Ness.default
  .httpRequest(.get, withUrl: "https://myurl.com")
  ..
  ..
  .dataRequest(with: myRetryControl)
```
It can be applicable for download or upload requests too.

iONess has some default `RetryControl` which is `CounterRetryControl` that the basic algorithm is just counting the failure time and stop retry when the counter reaches the maxCount. to use it, just init the `CounterRetryControl` when preparing with your maxCount or optionally with TimeInterval before retry. For example, if you want to auto-retry maximum of 3 times with a delay of 1 second for every retry:

```swift
Ness.default
  .httpRequest(.get, withUrl: "https://myurl.com")
  ..
  ..
  .dataRequest(
    with: CounterRetryControl(
      maxRetryCount: 3, 
      timeIntervalBeforeTryToRetry: 1
    )
  )
```

### DuplicatedHandler

You can handle what to do if there are multiple duplicated request happen with `DuplicatedHandler`:

```swift
public protocol DuplicatedHandler {
  func duplicatedDownload(request: URLRequest, withPreviousCompletion previousCompletion: @escaping URLCompletion<URL>, currentCompletion: @escaping URLCompletion<URL>) -> RequestDuplicatedDecision<URL>
  func duplicatedUpload(request: URLRequest, withPreviousCompletion previousCompletion: @escaping URLCompletion<Data>, currentCompletion: @escaping URLCompletion<Data>) -> RequestDuplicatedDecision<Data>
  func duplicatedData(request: URLRequest, withPreviousCompletion previousCompletion: @escaping URLCompletion<Data>, currentCompletion: @escaping URLCompletion<Data>) -> RequestDuplicatedDecision<Data>
}
```

It will ask for `RequestDuplicatedDecision` depending on what type of duplicated request. The `RequestDuplicatedDecision` are enumeration with members:
- `dropAndRequestAgain` which will drop the previous request and do a new request with the current completion
- `dropAndRequestAgainWithCompletion((Param?, URLResponse?, Error?) -> Void)` which will drop previous request and do new request with custom completion
- `ignoreCurrentCompletion` which will ignore the current completion, so when the request is complete, it will just run the first request completion
- `useCurrentCompletion` which will ignore the previous completion, so when the request is complete, it will just run the lastest request completion
- `useBothCompletion` which will keep the previous completion, so when the request is complete, it will just run all the request completion
- `useCompletion((Param?, URLResponse?, Error?) -> Void)` which will ignore all completion and use the custom one

The duplicatedHandler is stick to the `Ness` \ `NetworkSessionManager`, so if you have duplicated request with different `Ness` \ `NetworkSessionManager`, it should not be called.

To assign `RequestDuplicatedDecision`, you can just assign it to `duplicatedHandler` property, or just add it when init:

```swift
// just handler
let ness = Ness(duplicatedHandler: myHandler)

// with session
let ness = Ness(session: mySession, duplicatedHandler: myHandler)

// using property
ness.duplicatedHandler = myHandler
```

Or you can just use some default handler:

```swift
// just handler
let ness = Ness(onDuplicated: .keepAllCompletion)

// with session
let ness = Ness(session: mySession, onDuplicated: .keepFirstCompletion)

// using property
ness.duplicatedHandler = DefaultDuplicatedHandler.keepLatestCompletion
```

There are 4 `DefaultDuplicatedHandler`: 
- `dropPreviousRequest` which will drop the previous request and do a new request with the current completion
- `keepAllCompletion` will keep the previous completion, so when the request is complete, it will just run all the request completion
- `keepFirstCompletion` which will ignore the current completion, so when the request is complete, it will just run the first request completion
- `keepLatestCompletion` which will ignore the previous completion, so when the request is complete, it will just run the lastest request completion

## Contribute

You know how, just clone and do pull request
