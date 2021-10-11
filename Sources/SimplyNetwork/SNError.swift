//
//  SNError.swift
//  InDev SimplyNetwork
//
//  Created by Arnaud NOMMAY on 14/09/2021.
//

import Foundation

enum ConfigurationError: Error {
    case missingUrl
    case unknowError
    case failQerryParam
}

public enum SimplyNetworkError: Error {
    case invalidURL
    case notFound
    case unauthorized
    case badRequest
    case forbidden
    case internalServerError
    case unknowError(statusCode: Int)
    case decodingJSON
    case noDataFound
}

extension ConfigurationError {
    public var errorDescription: String? {
        switch self {
        case .unknowError:
            return NSLocalizedString("Parameters Error [⚠️]: While passing parameters in the request", comment: "ConfigurationError")
        case .missingUrl:
            return NSLocalizedString("Missing URL [⚠️]: Missing absulute url in request url", comment: "ConfigurationError")
        case .failQerryParam:
            return NSLocalizedString("Parameters Error [⚠️]: Unable to query parameters", comment: "ConfigurationError")
        }
    }
}

extension SimplyNetworkError: Equatable {
    public static func == (lhs: SimplyNetworkError, rhs: SimplyNetworkError) -> Bool {
        switch(lhs, rhs) {
        case (.invalidURL, .invalidURL):
            return true
        case (.notFound, .notFound):
            return true
        case (.unauthorized, .unauthorized):
            return true
        case (.badRequest, .badRequest):
            return true
        case (.forbidden, .forbidden):
            return true
        case (.internalServerError, .internalServerError):
            return true
        case (.unknowError(statusCode: let lhsCode), .unknowError(statusCode: let rhsCode)):
            return lhsCode == rhsCode
        case (.decodingJSON, .decodingJSON):
            return true
        case (.noDataFound, .noDataFound):
            return true
        default:
            return false
        }
    }
}

extension SimplyNetworkError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .invalidURL:
            return NSLocalizedString("INVALID URL [⛔️]: You request an invalid url.", comment: "SimplyNetworkError")
        case .notFound:
            return NSLocalizedString("404 NOT FOUND [⛔️]: The server can not find the requested resource ", comment: "SimplyNetworkError")
        case .unauthorized:
            return NSLocalizedString("401 UNAUTHORIZED [⛔️]: The client must authenticate itself to get the requested response.", comment: "SimplyNetworkError")
        case .badRequest:
            return NSLocalizedString("400 BAD REQUEST [⛔️]: The server could not understand the request due to invalid syntax.", comment: "SimplyNetworkError")
        case .forbidden:
            return NSLocalizedString("403 FORBIDDEN [⛔️]: The client does not have access rights to the content.", comment: "SimplyNetworkError")
        case .internalServerError:
            return NSLocalizedString("500 INTERNAL SERVER ERROR [⛔️]: The server has encountered a situation it doesn't know how to handle.", comment: "SimplyNetworkError")
        case .unknowError(let statusCode):
            return NSLocalizedString("ERROR \(statusCode) [⛔️]: The server return \(statusCode) code.", comment: "SimplyNetworkError")
        case .decodingJSON:
            return NSLocalizedString("JSON DECODING [⚠️]: An error occured will trying to decode JSON object.", comment: "SimplyNetworkError")
        case .noDataFound:
            return NSLocalizedString("NO DATA FOUND [⚠️]: No data found while performing the request.", comment: "SimplyNetworkError")
        }
    }
}

