//
//  UploadTests.swift
//  SimplyNetworkTests
//
//  Created by Arnaud NOMMAY on 05/10/2021.
//

import XCTest
@testable import SimplyNetwork


class UploadTests: XCTestCase {
    
    func testuploadData() {
        // Given
        let url = "https://httpbin.org/post"
        let promise = expectation(description: "Completion handler invoked")
        var error: Error?
        var dataRes: Data?
        let dataSend: Data! = "Café".data(using: .utf8)
        
        // When
        try? SN.uploadFile(dataToSend: dataSend, to: url) { (result: Result<(Data, URLResponse), Error>) in
            switch result {
            case .success((let dat, _)):
                dataRes = dat
            case .failure(let err):
                error = err
            }
            promise.fulfill()
        }
        wait(for: [promise], timeout: 5)
        
        // Then
        XCTAssertNotNil(dataRes)
        XCTAssertNil(error)
    }
    
    func testuploadFile() {
        // Given
        let url = "https://httpbin.org/post"
        let promise = expectation(description: "Completion handler invoked")
        var error: Error?
        var dataRes: Data?
        let fileURL = URL(string: "fileURL")!
        
        // When
        try? SN.uploadFile(fileURL: fileURL, to: url) { (result: Result<(Data, URLResponse), Error>) in
            switch result {
            case .success((let dat, _)):
                dataRes = dat
            case .failure(let err):
                error = err
            }
            promise.fulfill()
        }
        wait(for: [promise], timeout: 5)
        
        // Then
        XCTAssertNotNil(dataRes)
        XCTAssertNil(error)
    }
    
    func testDataRequestCodeUnknow() {
        // Given
        let url = "https://httpbin.org/status/300"
        let promise = expectation(description: "Completion handler invoked")
        var error: Error?
        var response: URLResponse?
        var dataRes: Data?
        let dataSend: Data! = "Café".data(using: .utf8)
        
        // When
        try? SN.uploadFile(dataToSend: dataSend, to: url) { (result: Result<(Data, URLResponse), Error>) in
            switch result {
            case .failure(let err):
                error = err // not
            case .success((let dat, let res)):
                dataRes = dat
                response = res
            }
            promise.fulfill()
        }
        wait(for: [promise], timeout: 5)
        
        // Then
        XCTAssertNil(dataRes)
        XCTAssertNil(response)
        XCTAssertNotNil(error)
        XCTAssertEqual((error as? SimplyNetworkError), .unknowError(statusCode: 300))
    }
    
    func testUploadDataURLInvalid() throws {
        // Given
        let url = "This is invalide"
        let dataSend: Data! = "Café".data(using: .utf8)
        
        XCTAssertThrowsError(try SN.uploadFile(dataToSend: dataSend, to: url, completion: {_ in }), "invalidURL") { error in
            XCTAssertEqual(error as? SimplyNetworkError, .invalidURL)
        }
    }
    
    func testUploadURLInvalid() throws {
        // Given
        let url = "This is invalide"
        let fileURL = URL(string: "fileURL")!
        
        XCTAssertThrowsError(try SN.uploadFile(fileURL: fileURL, to: url, completion: {_ in }), "invalidURL") { error in
            XCTAssertEqual(error as? SimplyNetworkError, .invalidURL)
        }
    }
    
    
}
