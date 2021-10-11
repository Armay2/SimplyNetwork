//
//  File.swift
//  
//
//  Created by Arnaud NOMMAY on 06/10/2021.
//

import XCTest
@testable import SimplyNetwork

class CodableRequestTests: SimplyNetworkTests {
    
    func testCodableRequestCodeSuccess() {
        // Given
        let url = "http://www.boredapi.com/api/activity/"
        let promise = expectation(description: "Completion handler invoked")
        var error: Error?
        var activityTitle: String?
        
        // When
        try? SN.request(url) { (result: Result<(Activity, URLResponse), Error>) in
            switch result {
            case .success((let acti, _)):
                activityTitle = acti.activity
            case .failure(let err):
                error = err
            }
            promise.fulfill()
        }
        wait(for: [promise], timeout: 5)
        
        // Then
        XCTAssertNotNil(activityTitle)
        XCTAssertNil(error)
    }
    
    func testCodableRequestCodeValue() {
        // Given
        let url = "https://httpbin.org/json"
        let promise = expectation(description: "Completion handler invoked")
        var error: Error?
        var slideshowAuthor: String?
        
        // When
        try? SN.request(url) { (result: Result<(Welcome, URLResponse), Error>) in
            switch result {
            case .success((let wel, _)):
                slideshowAuthor = wel.slideshow.author
            case .failure(let err):
                error = err
            }
            promise.fulfill()
        }
        wait(for: [promise], timeout: 5)
        
        // Then
        XCTAssertEqual(slideshowAuthor, "Yours Truly")
        XCTAssertNil(error)
    }
    
    func testCodableRequestParameters() {
        // Given
        let url = "https://httpbin.org/json"
        let promise = expectation(description: "Completion handler invoked")
        var error: Error?
        var slideshowAuthor: String?
        
        let parameters: [String: String] = [
            "username": "michel@michel.com",
            "password": "michel",
            "locale": "en-gb"]
        var headers = HTTPHeaders()
        headers.add(name: "Content-Type", value: "application/x-www-form-urlencoded")
        headers.add(name: "Accept", value: "application/json")
        
        // When
        try? SN.request(url,method: .get ,parameters: parameters, headers: headers) { (result: Result<(Welcome, URLResponse), Error>) in
            switch result {
            case .success((let wel, _)):
                slideshowAuthor = wel.slideshow.author
            case .failure(let err):
                error = err
            }
            promise.fulfill()
        }
        wait(for: [promise], timeout: 5)
        
        // Then
        XCTAssertEqual(slideshowAuthor, "Yours Truly")
        XCTAssertNil(error)
    }
    
    func testCodableRequestForceDestionation() {
        // Given
        let url = "https://httpbin.org/anything"
        let promise = expectation(description: "Completion handler invoked")
        var error: Error?
        var value1, value2, method: String?
        var headers = HTTPHeaders()
        
        let parameters: [String: String] = [
            "value1": "joe",
            "value2": "michel"]
        
        headers.add(name: "Content-Type", value: "application/x-www-form-urlencoded")
        headers.add(name: "Accept", value: "application/json")
        headers.add(name: "Sec-Fetch-Dest", value: "document")
        headers.add(name: "Sec-Fetch-Mode", value: "navigate")
        headers.add(name: "Sec-Fetch-Site", value: "none")
        headers.add(name: "Sec-Fetch-User", value: "?1")
        headers.add(name: "Sec-Gpc", value: "1")
        headers.add(name: "Upgrade-Insecure-Requests", value: "1")
        
        // When
        try? SN.request(url, method: .post, parameters: parameters, headers: headers, paramDestination: .queryString) { (result: Result<(Tester, URLResponse), Error>) in
            switch result {
            case .success((let test, _)):
                value1 = test.args.value1
                value2 = test.args.value2
                method = test.method
            case .failure(let err):
                error = err
            }
            promise.fulfill()
        }
        wait(for: [promise], timeout: 5)
        
        // Then
        XCTAssertEqual(value1, "joe")
        XCTAssertEqual(value2, "michel")
        XCTAssertEqual(method, "POST")
        XCTAssertNil(error)
    }
    
    func testCodableRequestForce() {
        // Given
        let url = "https://httpbin.org/anything?value1=joe&value2=michel"
        let promise = expectation(description: "Completion handler invoked")
        var error: Error?
        var value1, value2, method: String?
        var headers = HTTPHeaders()
        
        headers.add(name: "Content-Type", value: "application/x-www-form-urlencoded")
        headers.add(name: "Accept", value: "application/json")
        headers.add(name: "Sec-Fetch-Dest", value: "document")
        headers.add(name: "Sec-Fetch-Mode", value: "navigate")
        headers.add(name: "Sec-Fetch-Site", value: "none")
        headers.add(name: "Sec-Fetch-User", value: "?1")
        headers.add(name: "Sec-Gpc", value: "1")
        headers.add(name: "Upgrade-Insecure-Requests", value: "1")
        
        // When
        try? SN.request(url, method: .post, headers: headers, paramDestination: .queryString) { (result: Result<(Tester, URLResponse), Error>) in
            switch result {
            case .success((let test, _)):
                value1 = test.args.value1
                value2 = test.args.value2
                method = test.method
            case .failure(let err):
                error = err
            }
            promise.fulfill()
        }
        wait(for: [promise], timeout: 5)
        
        // Then
        XCTAssertEqual(value1, "joe")
        XCTAssertEqual(value2, "michel")
        XCTAssertEqual(method, "POST")
        XCTAssertNil(error)
    }
    
    func testCodableRequestCode404() {
        // Given
        let url = "https://httpbin.org/status/404"
        let promise = expectation(description: "Completion handler invoked")
        var error: Error?
        var title: String?
        var response: URLResponse?
        
        // When
        try? SN.request(url) { (result: Result<(Activity, URLResponse), Error>) in
            switch result {
            case .failure(let err):
                error = err // not
            case .success((let dat, let res)):
                title = dat.activity
                response = res
            }
            promise.fulfill()
        }
        wait(for: [promise], timeout: 5)
        
        // Then
        XCTAssertNil(title)
        XCTAssertNil(response)
        XCTAssertNotNil(error)
        XCTAssertEqual((error as? SimplyNetworkError), .notFound)
    }
    
    func testCodableRequestCodeUnknow() {
        // Given
        let url = "https://httpbin.org/status/300"
        let promise = expectation(description: "Completion handler invoked")
        var error: Error?
        var title: String?
        var response: URLResponse?
        
        // When
        try? SN.request(url) { (result: Result<(Activity, URLResponse), Error>) in
            switch result {
            case .failure(let err):
                error = err // not
            case .success((let dat, let res)):
                title = dat.activity
                response = res
            }
            promise.fulfill()
        }
        wait(for: [promise], timeout: 5)
        
        // Then
        XCTAssertNil(title)
        XCTAssertNil(response)
        XCTAssertNotNil(error)
        XCTAssertEqual((error as? SimplyNetworkError), .unknowError(statusCode: 300))
    }
    
    func testCodableRequestURLInvalid() throws {
        // Given
        let url = "This is invalide"
        
        XCTAssertThrowsError(try SN.request(url, {_ in }), "invalidURL") { (error) in
            XCTAssertEqual(error as? SimplyNetworkError, .invalidURL)
        }
    }
    
}

