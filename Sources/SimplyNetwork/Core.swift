//
//  Core.swift
//  InDev SimplyNetwork
//
//  Created by Arnaud NOMMAY on 14/09/2021.
//

import Foundation

open class Core {
    
    public static let `default` = Core()

    // MARK: - WIP Request
    
    // Image
    
    /// Return a `Data` object after prossesing an http request
    /// - Parameters:
    ///   - strUrl: The `String` for the request
    ///   - methode: The `HTTPMethod` for the request, default is GET
    ///   - parameters: The `Parameters` for the request
    ///   - headers: The `HTTPHeaders` for the request
    ///   - completion: The callback called after retrieval
    open func request(_ strUrl: String,
                      methode: HTTPMethod = .get,
                      parameters: Parameters? = nil,
                      headers: HTTPHeaders? = nil,
                      _ completion: @escaping (Result<(Data?, URLResponse), Error>) -> Void) {
        guard let requestUrl = URL(string: strUrl) else {
            debug("Invalid URL")
            completion(.failure(SimplyNetworkError.invalidURL))
            return
        }
        var request = configureURLRequest(for: requestUrl, methode: methode, parameters: parameters, headers: headers)
        
        if let parameters = parameters {
            let jsonData = try? JSONSerialization.data(withJSONObject: parameters)
            request.httpBody = jsonData
        }
        
        let dataTask = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
            } else if let data = data, let response = response {
                guard let response = response as? HTTPURLResponse else { return }
                if response.statusCode == 200 {
                    completion(.success((data, response)))
                    print("My data \(String(decoding: data, as: UTF8.self))")
                } else {
                    let simplyNError = self.errorFromStatusCode(for: response.statusCode)
                    completion(.failure(simplyNError))
                }
                completion(.success((nil, response)))
            }
        }
        dataTask.resume()
    }
    
    
    /// Return a `Codable` object after prossesing an http request
    ///
    /// - Parameters:
    ///   - strUrl: The `String` for the request
    ///   - methode: The `HTTPMethod` for the request, default is GET
    ///   - parameters: The `Parameters` for the request
    ///   - headers: The `HTTPHeaders` for the request
    ///   - completion: The callback called after retrieval
    open func request<CodableData: Codable>(_ strUrl: String,
                      methode: HTTPMethod = .get,
                      parameters: Parameters? = nil,
                      headers: HTTPHeaders? = nil,
                      _ completion: @escaping (Result<(CodableData?, URLResponse), Error>) -> Void) {
        guard let requestUrl = URL(string: strUrl) else {
            debug("Invalid URL")
            completion(.failure(SimplyNetworkError.invalidURL))
            return
        }
        var request = configureURLRequest(for: requestUrl, methode: methode, parameters: parameters, headers: headers)

        if let parameters = parameters {
            let jsonData = try? JSONSerialization.data(withJSONObject: parameters)
            request.httpBody = jsonData
        }
        
        let dataTask = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
            } else if let data = data, let response = response {
                guard let response = response as? HTTPURLResponse else { return }
                if response.statusCode == 200 {
                    DispatchQueue.main.async {
                        do {
                            let decodedJSON = try JSONDecoder().decode(CodableData.self, from: data)
                            completion(.success((decodedJSON, response)))
                            print("My decodedJson \(String(describing: decodedJSON))")
                        } catch let error {
                            print("Error decoding: ", error)
                        }
                    }
                } else {
                    let simplyNError = self.errorFromStatusCode(for: response.statusCode)
                    if simplyNError == .UnknowError {
                        completion(.success((nil, response)))
                    } else {
                        completion(.failure(simplyNError))
                    }
                }
                completion(.success((nil, response)))
            }
        }
        dataTask.resume()
    }
    
    // MARK: - Setup
    private func configureURLRequest(for requestUr: URL,
                                     methode: HTTPMethod = .get,
                                     parameters: Parameters? = nil,
                                     headers: HTTPHeaders? = nil) -> URLRequest {
        var request = URLRequest(url: requestUr)
        
        request.httpMethod = methode.rawValue

        request.setValue("application/json", forHTTPHeaderField: "Accept")
        if headers != nil {
            headers?.forEach({ header in
                request.addValue(header.value, forHTTPHeaderField: header.description)
            })
        }
        return request
    }
    
    
    // MARK: - Error
    private func errorFromStatusCode(for statusCode: Int) -> SimplyNetworkError {
        switch statusCode {
        case 404:
            return SimplyNetworkError.invalidURL
        default:
            return SimplyNetworkError.UnknowError
        }
    }
    
    // MARK: - Debug
    
    func debug(_ msg: String) {
        #if DEBUG
            fatalError(msg)
        #elseif RELEASE
            print(msg)
        #endif
    }
}
