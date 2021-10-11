//
//  RequestBasicError.swift
//  
//
//  Created by Arnaud NOMMAY on 11/10/2021.
//

import XCTest
@testable import SimplyNetwork

class RequestBasicError: SimplyNetworkTests {
    
    func testDataRequestCodeUnknow() {
        // Given
        let url = "https://httpbin.org/status/300"
        let promise = expectation(description: "Completion handler invoked")
        var error: Error?
        var data: Data?
        var response: URLResponse?
        
        // When
        try? SN.request(url) { (result: Result<(Data, URLResponse), Error>) in
            switch result {
            case .failure(let err):
                error = err // not
            case .success((let dat, let res)):
                data = dat
                response = res
            }
            promise.fulfill()
        }
        wait(for: [promise], timeout: 5)
        
        // Then
        XCTAssertNil(data)
        XCTAssertNil(response)
        XCTAssertNotNil(error)
        XCTAssertEqual((error as? SimplyNetworkError), .unknowError(statusCode: 300))
    }
    
    func testDataRequestCode404() {
        // Given
        let url = "https://httpbin.org/status/404"
        let promise = expectation(description: "Completion handler invoked")
        var error: Error?
        var data: Data?
        var response: URLResponse?
        
        // When
        try? SN.request(url) { (result: Result<(Data, URLResponse), Error>) in
            switch result {
            case .failure(let err):
                error = err // not
            case .success((let dat, let res)):
                data = dat
                response = res
            }
            promise.fulfill()
        }
        wait(for: [promise], timeout: 5)
        
        // Then
        XCTAssertNil(data)
        XCTAssertNil(response)
        XCTAssertNotNil(error)
        XCTAssertEqual((error as? SimplyNetworkError), .notFound)
    }
    
    func testDataRequestCode401() {
        // Given
        let url = "https://httpbin.org/status/401"
        let promise = expectation(description: "Completion handler invoked")
        var error: Error?
        var data: Data?
        var response: URLResponse?
        
        // When
        try? SN.request(url) { (result: Result<(Data, URLResponse), Error>) in
            switch result {
            case .failure(let err):
                error = err // not
            case .success((let dat, let res)):
                data = dat
                response = res
            }
            promise.fulfill()
        }
        wait(for: [promise], timeout: 5)
        
        // Then
        XCTAssertNil(data)
        XCTAssertNil(response)
        XCTAssertNotNil(error)
        XCTAssertEqual((error as? SimplyNetworkError), .unauthorized)
    }
    
    func testDataRequestCode400() {
        // Given
        let url = "https://httpbin.org/status/400"
        let promise = expectation(description: "Completion handler invoked")
        var error: Error?
        var data: Data?
        var response: URLResponse?
        
        // When
        try? SN.request(url) { (result: Result<(Data, URLResponse), Error>) in
            switch result {
            case .failure(let err):
                error = err // not
            case .success((let dat, let res)):
                data = dat
                response = res
            }
            promise.fulfill()
        }
        wait(for: [promise], timeout: 5)
        
        // Then
        XCTAssertNil(data)
        XCTAssertNil(response)
        XCTAssertNotNil(error)
        XCTAssertEqual((error as? SimplyNetworkError), .badRequest)
    }
    
    func testDataRequestCode403() {
        // Given
        let url = "https://httpbin.org/status/403"
        let promise = expectation(description: "Completion handler invoked")
        var error: Error?
        var data: Data?
        var response: URLResponse?
        
        // When
        try? SN.request(url) { (result: Result<(Data, URLResponse), Error>) in
            switch result {
            case .failure(let err):
                error = err // not
            case .success((let dat, let res)):
                data = dat
                response = res
            }
            promise.fulfill()
        }
        wait(for: [promise], timeout: 5)
        
        // Then
        XCTAssertNil(data)
        XCTAssertNil(response)
        XCTAssertNotNil(error)
        XCTAssertEqual((error as? SimplyNetworkError), .forbidden)
    }
    
    func testDataRequestCode500() {
        // Given
        let url = "https://httpbin.org/status/500"
        let promise = expectation(description: "Completion handler invoked")
        var error: Error?
        var data: Data?
        var response: URLResponse?
        
        // When
        try? SN.request(url) { (result: Result<(Data, URLResponse), Error>) in
            switch result {
            case .failure(let err):
                error = err // not
            case .success((let dat, let res)):
                data = dat
                response = res
            }
            promise.fulfill()
        }
        wait(for: [promise], timeout: 5)
        
        // Then
        XCTAssertNil(data)
        XCTAssertNil(response)
        XCTAssertNotNil(error)
        XCTAssertEqual((error as? SimplyNetworkError), .internalServerError)
    }
    
}
