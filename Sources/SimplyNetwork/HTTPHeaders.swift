//
//  HTTPHeaders.swift
//  InDev SimplyNetwork
//
//  Created by Arnaud NOMMAY on 14/09/2021.
//

import Foundation


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
