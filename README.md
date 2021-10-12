

[![swift-version](https://img.shields.io/badge/swift-5.1-brightgreen.svg)](https://github.com/apple/swift)
[![swift-package-manager](https://img.shields.io/badge/package%20manager-compatible-brightgreen.svg?logo=data:image/svg+xml;base64,PD94bWwgdmVyc2lvbj0iMS4wIiBlbmNvZGluZz0iVVRGLTgiPz4KPHN2ZyB3aWR0aD0iNjJweCIgaGVpZ2h0PSI0OXB4IiB2aWV3Qm94PSIwIDAgNjIgNDkiIHZlcnNpb249IjEuMSIgeG1sbnM9Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnIiB4bWxuczp4bGluaz0iaHR0cDovL3d3dy53My5vcmcvMTk5OS94bGluayI+CiAgICA8IS0tIEdlbmVyYXRvcjogU2tldGNoIDYzLjEgKDkyNDUyKSAtIGh0dHBzOi8vc2tldGNoLmNvbSAtLT4KICAgIDx0aXRsZT5Hcm91cDwvdGl0bGU+CiAgICA8ZGVzYz5DcmVhdGVkIHdpdGggU2tldGNoLjwvZGVzYz4KICAgIDxnIGlkPSJQYWdlLTEiIHN0cm9rZT0ibm9uZSIgc3Ryb2tlLXdpZHRoPSIxIiBmaWxsPSJub25lIiBmaWxsLXJ1bGU9ImV2ZW5vZGQiPgogICAgICAgIDxnIGlkPSJHcm91cCIgZmlsbC1ydWxlPSJub256ZXJvIj4KICAgICAgICAgICAgPHBvbHlnb24gaWQ9IlBhdGgiIGZpbGw9IiNEQkI1NTEiIHBvaW50cz0iNTEuMzEwMzQ0OCAwIDEwLjY4OTY1NTIgMCAwIDEzLjUxNzI0MTQgMCA0OSA2MiA0OSA2MiAxMy41MTcyNDE0Ij48L3BvbHlnb24+CiAgICAgICAgICAgIDxwb2x5Z29uIGlkPSJQYXRoIiBmaWxsPSIjRjdFM0FGIiBwb2ludHM9IjI3IDI1IDMxIDI1IDM1IDI1IDM3IDI1IDM3IDE0IDI1IDE0IDI1IDI1Ij48L3BvbHlnb24+CiAgICAgICAgICAgIDxwb2x5Z29uIGlkPSJQYXRoIiBmaWxsPSIjRUZDNzVFIiBwb2ludHM9IjEwLjY4OTY1NTIgMCAwIDE0IDYyIDE0IDUxLjMxMDM0NDggMCI+PC9wb2x5Z29uPgogICAgICAgICAgICA8cG9seWdvbiBpZD0iUmVjdGFuZ2xlIiBmaWxsPSIjRjdFM0FGIiBwb2ludHM9IjI3IDAgMzUgMCAzNyAxNCAyNSAxNCI+PC9wb2x5Z29uPgogICAgICAgIDwvZz4KICAgIDwvZz4KPC9zdmc+)](https://github.com/apple/swift-package-manager)
[![Platforms](https://img.shields.io/badge/Plateforms-macOS%20iOS%20tvOS%20watchOS-brightgreen)](https://img.shields.io/badge/Plateforms-macOS%20iOS%20tvOS%20watchOS-brightgreen)

![SimpleNetworkBanner](Resources/SimpleNetworkBanner.png)


# Table of content

- [About](#about)
- [Installat on](#installation)
- [Expemples](#Expemples)
- [Contributing](#Contributing)

<!-- ABOUT -->
## About
This is a package usefull to make simple HTTP requests and upload some files.

<!-- INSTALLATION -->
## Installation

### Swift Package Manager

The [Swift Package Manager](https://swift.org/package-manager/) is a tool for automating the distribution of Swift code and is integrated into the `swift` compiler. 

Once you have your Swift package set up, adding Simple Newtwork as a dependency is as easy as adding it to the `dependencies` value of your `Package.swift`.

```swift
dependencies: [
    .package(url: "https://github.com/Armay2/SimplyNetwork", .upToNextMajor(from: "5.4.0"))
]
```

<!-- BASIC EXEMPLES -->
## Expemples

We provide you diffrents methods for making HTTP requests 

This is one way of making a request. The full definition looks like this

```swift 
 open func request<T: Codable>(_ strUrl: String,
                                  method: HTTPMethod = .get,
                                  parameters: Parameters? = nil,
                                  headers: HTTPHeaders? = nil,
                                  paramDestination: ParamDestination? = .methodDependent,
                                  _ completion: @escaping CodableRequestCompletion<T>) throws {
```
Notice that's not the only definition, you can also request directly some data. 

### Simple request

**Request Codable Object**

Call request with determide object to decode 

```swift
var myObject: MyObject?
	
SN.request("https://yourUrl/content/") { (result: Result<(MyObject, URLResponse), Error>) in
	switch result {
	case .success((let object, let response)):
		myObject = object
		print(response)
	case .failure(let err):
		print(error)
	}
}
```
Your Object must conform to `Codable` Protocol
	
	
**Request some data**

```swift
try? SN.request(url) { (result: Result<(Data, URLResponse), Error>) in
	switch result {
	case .success((let dat, _)):
		data = dat
	case .failure(let err):
		error = err
	}
}
```


### Request with full configuration
```swift
let parameters: [String: String] = [
        "username": "name@doamin.com",
        "password": "password",
        "locale": "en-gb"]
var headers = HTTPHeaders()
headers.add(name: "Content-Type", value: "application/x-www-form-urlencoded")
headers.add(name: "Accept", value: "application/json")

    
try? SN.request("https://httpbin.org", method: .post, parameters: parameters, headers: headers, paramDestination: .httpBody) { (result: Result<(MyObject, URLResponse), Error>) in
	switch result {
	case .success((let obj, let response)):
		print(obj)
		print(response)
	case .failure(let err):
		print(error)
	}
}
```

### Upload a file
```swift
open func uploadFile(fileURL: URL,
                         to targetURL: String,
                         completion: @escaping DataRequestCompletion) throws {
                         
open func uploadFile(dataToSend: Data,
                         to targetURL: String,
                         completion: @escaping DataRequestCompletion) throws {                        
```



<!-- CONTRIBUTING -->
## Contributing

Contributions are what make the open source community such an amazing place to learn, inspire, and create. Any contributions you make are **greatly appreciated**.

1. Fork the Project
2. Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
3. Commit your Changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the Branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request



<!-- LICENSE -->
## License

Distributed under the MIT License. See `LICENSE` for more information.



<!-- CONTACT -->
## Contact

Arnaud: [@NAUNAU22](https://twitter.com/NAUNAU22) 

Project Link: [https://github.com/Armay2/SimplyNetwork](https://github.com/Armay2/SimplyNetworke)
