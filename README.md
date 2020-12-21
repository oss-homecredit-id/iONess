# iONess

iONess (iOS Network Session) is HTTP Request Helper for iOS platform used by Home Credit Indonesia iOS App

![build](https://github.com/oss-homecredit-id/iONess/workflows/build/badge.svg)
![test](https://github.com/oss-homecredit-id/iONess/workflows/test/badge.svg)
[![Version](https://img.shields.io/cocoapods/v/iONess.svg?style=flat)](https://cocoapods.org/pods/iONess)
[![License](https://img.shields.io/cocoapods/l/iONess.svg?style=flat)](https://cocoapods.org/pods/iONess)
[![Platform](https://img.shields.io/cocoapods/p/iONess.svg?style=flat)](https://cocoapods.org/pods/iONess)

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

## Installation

iONess is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'iONess'
```

## Contributor

- Home Credit Indonesia, iOS Teams
- nayanda, nayanda1@outlook.com

## License

iONess is available under the MIT license. See the LICENSE file for more info.

## Usage Example

### Basic Usage

`iONess` is designed to simplify the request process for HTTP Request. All you need to do is just create the request using `Ness` /  `NetworkSessionManager` class:

```swift
Ness.default
    .httpRequest(.get, withUrl: "https://myurl.com")
    .prepareDataRequest()
    .then { result in
    // do something with result ignoring its state (succeed or fail)
}
```

with failure handler:

```swift
Ness.default
    .httpRequest(.get, withUrl: "https://myurl.com")
    .prepareDataRequest()
    .then(
        run: { result in
            // do something with result
        },
        whenFailed: { result in
            // do something with error result
        }
    )
```

with finally:

```swift
Ness.default
    .httpRequest(.get, withUrl: "https://myurl.com")
    .prepareDataRequest()
    .then(
        run: { result in
            // do something with result
        },
        whenFailed: { result in
            // do something with error result
        },
        finally: { result in
            // do something after succeed or fail
        }
    )
```

or with no completion at all:

```swift
Ness.default
    .httpRequest(.get, withUrl: "https://myurl.com")
    .prepareDataRequest()
    .executeAndForget()
```

you can do something very readable like this by separating all closure using function:

```swift
Ness.default
    .httpRequest(.get, withUrl: "https://myurl.com")
    .prepareDataRequest()
    .then(
        run: updateTheViewWithData,
        whenFailed: showFailureAlert,
        finally: removeLoading
    )
```

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

it's better to save the instance of Ness and reused it since it will be just creating the request with same `URLSession` unless you want to use any other `URLSession` for other request.

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
the relatedHeaders is the associated header with this encoding which will auto assigned to the request headers. those method are optional since the default implementation are returning nil

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
    .prepareDataRequest()
```
or for download, you need to give target location `URL` where you want to downloaded data to be saved:

```swift
Ness.default.httpRequest(.get, withUrl: "https://myurl.com")
    .set(urlParameters: ["param1": "value1", "param2": "value2"])
    .set(headers: ["Authorization": myToken])
    .set(body: dataBody)
    ..
    ..
    .prepareDownloadRequest(targetSavedUrl: myTargetUrl)
```

or for updload you need to give file location `URL` which you want to upload:

```swift
Ness.default.httpRequest(.get, withUrl: "https://myurl.com")
    .set(urlParameters: ["param1": "value1", "param2": "value2"])
    .set(headers: ["Authorization": myToken])
    .set(body: dataBody)
    ..
    ..
    .prepareUploadRequest(withFileLocation: myTargetUrl)
```

### Data Request Thenable

After creating data request, you can just execute the request with then method:

```swift
Ness.default
    .httpRequest(.get, withUrl: "https://myurl.com")
    ..
    ..
    .prepareDataRequest()
    .then { result in
    // do something with result
}
```

Or with separate completion:

```swift
Ness.default
    .httpRequest(.get, withUrl: "https://myurl.com")
    ..
    ..
    .prepareDataRequest()
    .then(
        run: { result in
            // do something when get response
        }, 
        whenFailed: { result in
            // do something when failed
        }
    )
```

Or with finally completion:

```swift
Ness.default
    .httpRequest(.get, withUrl: "https://myurl.com")
    ..
    ..
    .prepareDataRequest()
    .then(
        run: { result in
            // do something when get response
        }, 
        whenFailed: { result in
            // do something when failed
        }, 
        finally: { result in
            // do something when after request finished
        }
    )
```

With custom dispatcher which will be the thread where completion run:

```swift
Ness.default
    .httpRequest(.get, withUrl: "https://myurl.com")
    ..
    ..
    .prepareDataRequest()
    .completionDispatch(on: .global(qos: .background))
    .then { result in
    // this block will run on DispatchQueue.global(qos: .background)
}
```

The default dispatcher is `DispatchQueue.main`

Or even without completion:

```swift
Ness.default
    .httpRequest(.get, withUrl: "https://myurl.com")
    ..
    ..
    .prepareDataRequest()
    .executeAndForget()
```

The result is `URLResult` object which contains:
- `urlResponse: URLResponse?` which is original response which you can read the documentation at [here](https://developer.apple.com/documentation/foundation/httpurlresponse)
- `error: Error?` which is error if happen. it will be nil on success response
- `responseData: Data?` which is raw data of the response body
- `isFailed: Bool` which is true if request is failed
- `isSucceed: Bool` which is true if request is success
- `httpMessage: HTTPResultMessage?` which is response message of the request. Will be nil if the result is not http result

The `HTTPResultMessage` is the detailed http response from the `URLResult`:
- `url: HTTPURLCompatible` which is origin url of the response
- `headers: Header` which is headers of the response
- `body: Data?` which is body of the response
- `statusCode: Int` which is statusCode of the response

You can get the thenable object or ignore it. It will return `HTTPRequest` which contains status of the request

```swift
let request = Ness.default
    .httpRequest(.get, withUrl: "https://myurl.com")
    ..
    ..
    .prepareDataRequest()
    .executeAndForget()
let status = request.status
```

The statuses are:
- `running(Float)` which contains percentage of request progress from 0 - 1
- `dropped`
- `idle`
- `completed(HTTPURLResponse)` which contains the completed response
- `error(Error)` which contains error if there are occurs

you can cancel the request using `drop()` function:

```swift
request.drop()
```

### Upload Request Thenable

Upload request basically are the same with Data request in terms of thenable.

### Download Request Thenable

Download request have slightly difference than data request or upload request. The download request can be paused and resumed, and the result is different

The result is `DownloadResult` object which contains:
- `urlResponse: URLResponse?` which is original response which you can read the documentation at [here](https://developer.apple.com/documentation/foundation/httpurlresponse)
- `error: Error?` which is error if happen. it will be nil on success response
- `dataLocalURL: URL?` which is the location of downloaded data
- `isFailed: Bool` which is true if request is failed
- `isSucceed: Bool` which is true if request is success

You can pause the download and resume:

```swift
request.pause()

let status = request.resume()
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
    .prepareDataRequest()
    .validate(statusCodes: 0..<300)
    .validate(shouldHaveHeaders: ["Content-Type": "application/json"])
    .then(run: { result in
        // do something when get response
    }, whenFailed: { result in
        // do something when failed
    }
)
```
If the response is not valid, then it will have error or dispacthed into whenFailed closure with error.

the provided validate method are:

- `validate(statusCode: Int) -> Self`
- `validate(statusCodes: Range<Int>) -> Self`
- `validate(shouldHaveHeaders headers: [String:String]) -> Self`

You can add custom validator to validate the http response. The type of validator is `URLValidator`:

```swift
public protocol URLValidator {
    func validate(for response: URLResponse) -> ValidationResult
}
```

`ValidationResult` is a enumeration which contains:
- `valid`
- `invalid`
- `invalidWithReason(String)` invalid with custom reason which will be a description on `HTTPError` Error

and put your custom `URLValidator` like this:

```swift
Ness.default
    .httpRequest(.get, withUrl: "https://myurl.com")
    ..
    ..
    .prepareDataRequest()
    .validate(using: MyCustomValidator())
    .then(run: { result in
        // do something when get response
    }, whenFailed: { result in
        // do something when failed
    }
)
```

You can use `HTTPValidator` if you want to validate only `HTTPURLResponse` and automatically invalidate the other:

```swift
public protocol HTTPValidator: URLValidator {
    func validate(forHttp response: HTTPURLResponse) -> URLValidatorResult
}
```

Remember you can put as many validator as you want, which will validate the response using all those validator from the first until end or until one validator return `invalid`
If you don't provide any `URLValidator`, then it will considered invalid if there's error or no response from the server, otherwise, all the response will be considered valid

### NetworkSessionManagerDelegate

You can manipulate request or action globally in Session level by using `NetworkSessionManagerDelegate`:

```swift
public protocol NetworkSessionManagerDelegate: class {
    func ness(_ manager: Ness, willRequest request: URLRequest) -> URLRequest
    func ness(_ manager: Ness, didRequest request: URLRequest) -> Void
}
```
both method are optional. The methods will run and functional for:
- `ness(_: , willRequest: )` will run before any request executed. You can manipulate `URLRequest` object here and return it or doing anything prior to request and return the current `URLRequest`
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

The method will run on failure request. The only thing you need to do is passing the `RetryControlDecision` into `didHaveDecision` closure which is enumeration with members:
- `noRetry` which will automatically fail the request
- `retryAfter(TimeInterval)` which will retry the same request after `TimeInterval`
- `retry` which will retry the same request immediately

You can assign `RetryControl` when preparing request:

```swift
Ness.default
    .httpRequest(.get, withUrl: "https://myurl.com")
    ..
    ..
    .prepareDataRequest(with: myRetryControl)
```
It can be applicable for download or upload request too.

iONess have some default `RetryControl` which is `CounterRetryControl` that the basic algorithm is just counting the failure time and stop retry when the counter reach the maxCount. to use it, just init the CounterRetryControl when prepare with your own maxCount or optionally with TimeInterval before retry. Example, if you want to auto retry maximum 3 times with delay 1 second for every retry:

```swift
Ness.default
    .httpRequest(.get, withUrl: "https://myurl.com")
    ..
    ..
    .prepareDataRequest(
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
- `dropAndRequestAgain` which will drop previous request and do new request with current completion
- `dropAndRequestAgainWithCompletion((Param?, URLResponse?, Error?) -> Void)` which will drop previous request and do new request with custom completion
- `ignoreCurrentCompletion` which will ignore the current completion, so when the request is complete, it will just run the first request completion
- `useCurrentCompletion` which will ignore the previous completion, so when the request is complete, it will just run the lastest request completion
- `useBothCompletion` which will keep the previous completion, so when the request is complete, it will just run the all the request completion
- `useCompletion((Param?, URLResponse?, Error?) -> Void)` which will ignore all completion and use the custom one

The duplicatedHandler are stick to the `Ness` \ `NetworkSessionManager`, so if you have duplicated request with different `Ness` \ `NetworkSessionManager`, it should not be called.

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
- `dropPreviousRequest` which will drop previous request and do new request with current completion
- `keepAllCompletion` which will keep the previous completion, so when the request is complete, it will just run the all the request completion
- `keepFirstCompletion` which will ignore the current completion, so when the request is complete, it will just run the first request completion
- `keepLatestCompletion` which will ignore the previous completion, so when the request is complete, it will just run the lastest request completion

### Aggregate

You can aggregate two or more request into one single Thenable like this:

```swift
request1.aggregate(with: request2)
    .aggregate(request3)
    .then { allResults in
    // do something with allResults
}

//or like this
RequestAggregator(aggregatedRequests)
    .then { allResults in
        // do something with allResults
}
```

the result are `RequestAggregator.Result` which contains:
- `results: [AggregatedResult]` which is all the completed results from aggregated requests
- `isFailed: Bool` which will be true if one or more request is failed
- `areCompleted: Bool` which will be true if all the request is completed

You can get the request too like single Request and get its status or drop it just like one request:

```swift
let aggregatedRequests = request1.aggregate(with: request2)
    .aggregate(request3)
    .then { allResults in
    // do something with allResults
}
let aggregatedStatus = aggregatedRequests.status
aggregatedRequests.drop()
```

## Contribute

You know how, just clone and do pull request
