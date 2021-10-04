//
//  SNError.swift
//  InDev SimplyNetwork
//
//  Created by Arnaud NOMMAY on 14/09/2021.
//

import Foundation

enum ConfigurationError: Error {
    case missingUrl
    case UnknowError
    case failQerryParam
}

enum SimplyNetworkError: Error {
    case invalidURL
    case notFound
    case unauthorized
    case badRequest
    case forbidden
    case internalServerError
    case UnknowError
}

extension ConfigurationError {
    public var errorDescription: String? {
        switch self {
        case .UnknowError:
            return NSLocalizedString("Parameters Error [⚠️]: While passing parameters in the request", comment: "ConfigurationError")
        case .missingUrl:
            return NSLocalizedString("Url Missing [⚠️]: Missing absulute url in request url", comment: "ConfigurationError")
        case .failQerryParam:
            return NSLocalizedString("Parameters Error [⚠️]: Unable to query parameters", comment: "ConfigurationError")
            
        }
    }
}

extension SimplyNetworkError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .invalidURL:
            return NSLocalizedString("INVALID URL [⛔️]: You request an invalid url ⛔️", comment: "SimplyNetworkError")
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
        case .UnknowError:
            return NSLocalizedString("UNKNOW ERROR [⚠️]: Uncommon error please refere to responce status code for more details.", comment: "SimplyNetworkError")
        }
    }
}
