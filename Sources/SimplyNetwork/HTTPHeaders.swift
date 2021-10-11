//
//  HTTPHeaders.swift
//  InDev SimplyNetwork
//
//  Created by Arnaud NOMMAY on 14/09/2021.
//

import Foundation

public enum HeaderContentType: String {
    case JSON = "application/json"
    case formUrlencoded = "application/x-www-form-urlencoded"
}

public struct HTTPHeaders {
    private var headers: [HTTPHeader] = []
    
    public init() {}
    
    public init(_ headers: [HTTPHeader]) {
        self.init()
        headers.forEach { update($0) }
    }
    
    public init(_ dictionary: [String: String]) {
        self.init()
        
        dictionary.forEach { update(HTTPHeader(name: $0.key, value: $0.value)) }
    }
    
    public mutating func add(name: String, value: String) {
        update(HTTPHeader(name: name, value: value))
    }
    
    public mutating func add(_ header: HTTPHeader) {
        update(header)
    }
    
    public mutating func update(name: String, value: String) {
        update(HTTPHeader(name: name, value: value))
    }
    
    public mutating func update(_ header: HTTPHeader) {
        guard let index = headers.index(of: header.name) else {
            headers.append(header)
            return
        }
        headers.replaceSubrange(index...index, with: [header])
    }
    
    public mutating func remove(name: String) {
        guard let index = headers.index(of: name) else { return }
        
        headers.remove(at: index)
    }
    
    public mutating func sort() {
        headers.sort { $0.name.lowercased() < $1.name.lowercased() }
    }
    
    public func value(for name: String) -> String? {
        guard let index = headers.index(of: name) else { return nil }
        
        return headers[index].value
    }
    
    public subscript(_ name: String) -> String? {
        get { value(for: name) }
        set {
            if let value = newValue {
                update(name: name, value: value)
            } else {
                remove(name: name)
            }
        }
    }
    
    public var dictionary: [String: String] {
        let namesAndValues = headers.map { ($0.name, $0.value) }
        
        return Dictionary(namesAndValues, uniquingKeysWith: { _, last in last })
    }
}


extension HTTPHeaders: Sequence {
    public func makeIterator() -> IndexingIterator<[HTTPHeader]> {
        headers.makeIterator()
    }
}

public struct HTTPHeader: Hashable {
    public let name: String
    public let value: String
    
    public init(name: String, value: String) {
        self.name = name
        self.value = value
    }
}

extension HTTPHeaders: Collection {
    public var startIndex: Int {
        headers.startIndex
    }
    
    public var endIndex: Int {
        headers.endIndex
    }
    
    public subscript(position: Int) -> HTTPHeader {
        headers[position]
    }
    
    public func index(after i: Int) -> Int {
        headers.index(after: i)
    }
}

extension HTTPHeader: CustomStringConvertible {
    public var description: String {
        "\(name): \(value)"
    }
}

extension Array where Element == HTTPHeader {
    func index(of name: String) -> Int? {
        let lowercasedName = name.lowercased()
        return firstIndex { $0.name.lowercased() == lowercasedName }
    }
}
