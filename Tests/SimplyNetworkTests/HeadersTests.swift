//
//  HeadersTests.swift
//  
//
//  Created by Arnaud NOMMAY on 11/10/2021.
//

import XCTest
@testable import SimplyNetwork

class HeadersTest: SimplyNetworkTests {
    
    func testInit() {
        // Given
        var headers = HTTPHeaders()
        let header = HTTPHeader(name: "headerName", value: "headerValue")
        let headers2 = HTTPHeaders(["headerName": "headerValue"])
        // When
        headers.add(header)
        
        // Then
        XCTAssertEqual(headers["headerName"], headers2["headerName"])
        
    }
    
    func testAddGetFirst() {
        // Given
        var headers = HTTPHeaders()
        let header = HTTPHeader(name: "headerName", value: "headerValue")
        
        // When
        headers.add(header)
        // Then
        
        XCTAssertEqual(headers.first, header)
    }
    
    func testRemoveName() {
        // Given
        var headers = HTTPHeaders()
        let header = HTTPHeader(name: "headerName", value: "headerValue")
        
        // When
        headers.add(header)
        headers.remove(name: "headerName")
        // Then
        
        XCTAssertNil(headers.first)
    }
    
    func testUpadate() {
        var headers = HTTPHeaders()
        let header = HTTPHeader(name: "headerName", value: "headerValue")
        
        // When
        headers.add(header)
        headers.update(name: "headerName", value: "newValue")
        // Then
        
        XCTAssertEqual(headers.first?.value, "newValue")
    }
    
    func testGetValueByName() {
        var headers = HTTPHeaders()
        let header = HTTPHeader(name: "headerName", value: "headerValue")
        
        // When
        headers.add(header)
        headers["headerName"] = "newValue"
        // Then
        
        XCTAssertEqual(headers["headerName"], "newValue")
    }
    
}
