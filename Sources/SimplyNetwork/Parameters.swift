//
//  Parameters.swift
//  InDev SimplyNetwork
//
//  Created by Arnaud NOMMAY on 14/09/2021.
//

import Foundation

public typealias Parameters = [String: Any]

public enum ParamDestination {
    case methodDependent
    case queryString
    case httpBody
}

public struct ParametersEncoder {
    
    /// The encoding to use for `Array` parameters.
    var arrayEncoding: ArrayEncoding = .brackets
    
    /// The encoding to use for `Bool` parameters.
    var boolEncoding: BoolEncoding = .numeric
    
    /// Configures how `Array` parameters are encoded.
    enum ArrayEncoding {
        /// An empty set of square brackets is appended to the key for every value. This is the default behavior.
        case brackets
        /// No brackets are appended. The key is encoded as is.
        case noBrackets
        
        func encode(key: String) -> String {
            switch self {
            case .brackets:
                return "\(key)[]"
            case .noBrackets:
                return key
            }
        }
    }
    
    /// Configures how `Bool` parameters are encoded.
    enum BoolEncoding {
        /// Encode `true` as `1` and `false` as `0`. This is the default behavior.
        case numeric
        /// Encode `true` and `false` as string literals.
        case literal
        
        func encode(value: Bool) -> String {
            switch self {
            case .numeric:
                return value ? "1" : "0"
            case .literal:
                return value ? "true" : "false"
            }
        }
    }
    
    // MARK: Initialization
    
    /// Creates an instance using the specified parameters.
    ///
    /// - Parameters:
    ///   - destination:   `Destination` defining where the encoded query string will be applied. `.methodDependent` by
    ///                    default.
    ///   - arrayEncoding: `ArrayEncoding` to use. `.brackets` by default.
    ///   - boolEncoding:  `BoolEncoding` to use. `.numeric` by default.
    init(arrayEncoding: ArrayEncoding = .brackets,
         boolEncoding: BoolEncoding = .numeric) {
        self.arrayEncoding = arrayEncoding
        self.boolEncoding = boolEncoding
    }
    
    // MARK: Encoding
    public func configureRequest(parameters: Parameters, request: inout URLRequest, destination: ParamDestination?) throws {
        do {
            if let destination = destination {
                switch destination {
                case .httpBody:
                    try configureHtttBody(parameters, &request)
                case .queryString:
                    try configQueryString(parameters, &request)
                default:
                    try selectMethod(parameters, &request, destination)
                }
            }
        } catch {
            throw error
        }
    }
    
    // TODO: Check if http header is correct ? -> "application/x-www-form-urlencoded
    
    /// Put parameters in the request body
    /// - Parameters:
    ///   - parameters: `Parameters` to querry
    ///   - request: Request that needed to be configure
    /// - Throws: Error of type `ConfigurationError`
    func configureHtttBody(_ parameters: Parameters, _ request: inout URLRequest) throws {
        guard let strParam = query(parameters) else {
            throw ConfigurationError.failQerryParam
        }
        
        if let bodyData = strParam.data(using: .utf8) {
            request.httpBody = bodyData
        }
    }
    
    /// Select where Parameters needed to be in the request, related to the request type and user selected destination
    /// - Parameters:
    ///   - parameters: `Parameters` to querry
    ///   - request: Request that needed to be configure
    ///   - destination: Parameters destination, could be in request url or in body, using the `queryString` or `httpBody` method
    /// - Throws: Error of type `ConfigurationError`
    func selectMethod(_ parameters: Parameters, _ request: inout URLRequest, _ destination: ParamDestination?) throws {
        do {
            if destination == .httpBody {
                try configureHtttBody(parameters, &request)
            } else if destination == .queryString {
                try configQueryString(parameters, &request)
            }
            if request.httpMethod == HTTPMethod.get.rawValue || request.httpMethod == HTTPMethod.head.rawValue || request.httpMethod == HTTPMethod.delete.rawValue {
                try configQueryString(parameters, &request)
            } else {
                try configureHtttBody(parameters, &request)
            }
        } catch {
            throw error
        }
    }
    
    /// Put parameters in the request url
    /// - Parameters:
    ///   - parameters: `Parameters` to querry
    ///   - request: Request that needed to be configure
    /// - Throws: Error of type `ConfigurationError`
    func configQueryString(_ parameters: Parameters, _ request: inout URLRequest) throws {
        var request = request
        guard var strUrl = request.url?.absoluteString else {
            throw ConfigurationError.missingUrl
        }
        guard let strParam = query(parameters) else {
            throw ConfigurationError.failQerryParam
        }
        
        strUrl = strUrl + "?" + strParam
        let newUrl = URL(string: strUrl)
        request = URLRequest(url: newUrl!)
    }
}

extension ParametersEncoder {
    
    func query( _ parameters: Parameters) -> String?  {
        var components: [(String, String)] = []
        
        for key in parameters.keys.sorted(by: <) {
            let value = parameters[key]!
            components += queryComponents(fromKey: key, value: value)
        }
        return components.map { "\($0)=\($1)" }.joined(separator: "&")
    }
    
    /// Creates a percent-escaped, URL encoded query string components from the given key-value pair recursively.
    ///
    /// - Parameters:
    ///   - key:   Key of the query component.
    ///   - value: Value of the query component.
    ///
    /// - Returns: The percent-escaped, URL encoded query string components.
    func queryComponents(fromKey key: String, value: Any) -> [(String, String)] {
        var components: [(String, String)] = []
        switch value {
        case let dictionary as [String: Any]:
            for (nestedKey, value) in dictionary {
                components += queryComponents(fromKey: "\(key)[\(nestedKey)]", value: value)
            }
        case let array as [Any]:
            for value in array {
                components += queryComponents(fromKey: arrayEncoding.encode(key: key), value: value)
            }
        case let number as NSNumber:
            if number.isBool {
                components.append((escape(key), escape(boolEncoding.encode(value: number.boolValue))))
            } else {
                components.append((escape(key), escape("\(number)")))
            }
        case let bool as Bool:
            components.append((escape(key), escape(boolEncoding.encode(value: bool))))
        default:
            components.append((escape(key), escape("\(value)")))
        }
        return components
    }
    
    func escape(_ string: String) -> String {
        string.addingPercentEncoding(withAllowedCharacters: .afURLQueryAllowed) ?? string
    }
    
}

extension NSNumber {
    fileprivate var isBool: Bool {
        // Use Obj-C type encoding to check whether the underlying type is a `Bool`, as it's guaranteed as part of
        // swift-corelibs-foundation, per [this discussion on the Swift forums](https://forums.swift.org/t/alamofire-on-linux-possible-but-not-release-ready/34553/22).
        String(cString: objCType) == "c"
    }
}

extension CharacterSet {
    /// Creates a CharacterSet from RFC 3986 allowed characters.
    ///
    /// RFC 3986 states that the following characters are "reserved" characters.
    ///
    /// - General Delimiters: ":", "#", "[", "]", "@", "?", "/"
    /// - Sub-Delimiters: "!", "$", "&", "'", "(", ")", "*", "+", ",", ";", "="
    ///
    /// In RFC 3986 - Section 3.4, it states that the "?" and "/" characters should not be escaped to allow
    /// query strings to include a URL. Therefore, all "reserved" characters with the exception of "?" and "/"
    /// should be percent-escaped in the query string.
    public static let afURLQueryAllowed: CharacterSet = {
        let generalDelimitersToEncode = ":#[]@" // does not include "?" or "/" due to RFC 3986 - Section 3.4
        let subDelimitersToEncode = "!$&'()*+,;="
        let encodableDelimiters = CharacterSet(charactersIn: "\(generalDelimitersToEncode)\(subDelimitersToEncode)")
        
        return CharacterSet.urlQueryAllowed.subtracting(encodableDelimiters)
    }()
}
