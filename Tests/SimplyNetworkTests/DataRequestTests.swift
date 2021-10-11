//
//  DataRequestTests.swift
//  SimplyNetworkTests
//
//  Created by Arnaud NOMMAY on 05/10/2021.
//

import XCTest
@testable import SimplyNetwork

class DataRequestTests: SimplyNetworkTests {
    
    
    func testDataRequestData() {
        // Given
        let url = "https://httpbin.org/status/200"
        let promise = expectation(description: "Completion handler invoked")
        var error: Error?
        var data: Data?
        
        // When
        try? SN.request(url) { (result: Result<(Data, URLResponse), Error>) in
            switch result {
            case .success((let dat, _)):
                data = dat
            case .failure(let err):
                error = err
            }
            promise.fulfill()
        }
        wait(for: [promise], timeout: 5)
        
        // Then
        XCTAssertNotNil(data)
        XCTAssertNil(error)
    }
    
    func testRequestParamBody() {
        // Given
        let url = "https://httpbin.org/status/200"
        let promise = expectation(description: "Completion handler invoked")
        var error: Error?
        var data: Data?
        
        let parameters: [String: String] = [
            "name": "joe",
            "password": "michel"]
        
        // When
        try? SN.request(url,method: .post ,parameters: parameters, paramDestination: .httpBody) { (result: Result<(Data, URLResponse), Error>) in
            switch result {
            case .success((let dat, _)):
                data = dat
            case .failure(let err):
                error = err
            }
            promise.fulfill()
        }
        wait(for: [promise], timeout: 5)
        
        // Then
        XCTAssertNotNil(data)
        XCTAssertNil(error)
    }
    
    func testDataRequestURLInvalid() throws {
        // Given
        let url = "This is invalide"
        
        XCTAssertThrowsError(try SN.request(url, {_ in }), "invalidURL") { (error) in
            XCTAssertEqual(error as? SimplyNetworkError, .invalidURL)
        }
    }
    
}
