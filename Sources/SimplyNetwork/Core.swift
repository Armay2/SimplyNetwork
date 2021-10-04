//
//  Core.swift
//  InDev SimplyNetwork
//
//  Created by Arnaud NOMMAY on 14/09/2021.
//

import Foundation

open class Core {
    
    public static let `default` = Core()
    private let parameterEncoder = ParametersEncoder()
    
    public typealias DataRequestCompletion = (Result<(Data?, URLResponse), Error>) -> Void
    public typealias CodableRequestCompletion<T: Codable> = (Result<(T?, URLResponse), Error>) -> Void
    


    // MARK: - Request
    
    /// Return a `Data` object after prossesing an http request
    /// - Parameters:
    ///   - strUrl: The `String` for the request
    ///   - method: The `HTTPMethod` for the request, default is GET
    ///   - parameters: The `Parameters` for the request
    ///   - headers: The `HTTPHeaders` for the request
    ///   - completion: The callback called after retrieval
    open func request(_ strUrl: String,
                      method: HTTPMethod = .get,
                      parameters: Parameters? = nil,
                      headers: HTTPHeaders? = nil,
                      paramDestination: ParamDestination? = .methodDependent,
                      _ completion: @escaping DataRequestCompletion) throws {
        let urlRequest: URLRequest?
        do {
            urlRequest = try configureURLRequest(for: strUrl, method: method, parameters: parameters, headers: headers, paramDestination: paramDestination)
        } catch {
            throw error
        }
        guard let request = urlRequest else { return }
        
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
    
    
    // Remplacer par "T"
    /// Return a `Codable` object after prossesing an http request
    ///
    /// - Parameters:
    ///   - strUrl: The `String` for the request
    ///   - method: The `HTTPMethod` for the request, default is GET
    ///   - parameters: The `Parameters` for the request
    ///   - headers: The `HTTPHeaders` for the request
    ///   - completion: The callback called after retrieval
    open func request<T: Codable>(_ strUrl: String,
                                  method: HTTPMethod = .get,
                                  parameters: Parameters? = nil,
                                  headers: HTTPHeaders? = nil,
                                  paramDestination: ParamDestination? = .methodDependent,
                                  _ completion: @escaping CodableRequestCompletion<T>) throws {
        let urlRequest: URLRequest?
        do {
            urlRequest = try configureURLRequest(for: strUrl, method: method, parameters: parameters, headers: headers, paramDestination: paramDestination)
        } catch {
            throw error
        }
        guard let request = urlRequest else { return }
        
        let dataTask = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
            } else if let data = data, let response = response {
                guard let response = response as? HTTPURLResponse else { return }
                if response.statusCode == 200 {
                    DispatchQueue.main.async {
                        do {
                            let decodedJSON = try JSONDecoder().decode(T.self, from: data)
                            completion(.success((decodedJSON, response)))
                        } catch let error {
                            completion(.failure(error))
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
    
    // TODO: Error handling to the caller
    private func configureURLRequest(for strUrl: String,
                                     method: HTTPMethod,
                                     parameters: Parameters?,
                                     headers: HTTPHeaders?,
                                     paramDestination: ParamDestination?) throws -> URLRequest {
        guard let requestUrl = URL(string: strUrl) else {
            debug("Invalid URL")
            throw SimplyNetworkError.invalidURL
        }
        var request = URLRequest(url: requestUrl)
        request.httpMethod = method.rawValue
        
        // Voir pour utiliser un enum ?
        if let headers = headers {
            headers.forEach({ header in
                request.addValue(header.value, forHTTPHeaderField: header.name)
            })
        }
        
        if let parameters = parameters {
            do {
                try parameterEncoder.configureRequest(parameters: parameters, request: &request, destination: paramDestination)
            } catch {
                throw error
            }
        }
        
        return request
    }
    
    
    // MARK: - Error
    private func errorFromStatusCode(for statusCode: Int) -> SimplyNetworkError {
        switch statusCode {
        case 404:
            return SimplyNetworkError.notFound
        case 401:
            return SimplyNetworkError.unauthorized
        case 400:
            return SimplyNetworkError.badRequest
        case 403:
            return SimplyNetworkError.forbidden
        case 500:
            return SimplyNetworkError.internalServerError
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


/*
 do {
 let jsonData = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted)
 let decoded = try JSONSerialization.jsonObject(with: jsonData, options: [])
 
 // Cast with the right type
 if let dictFromJSON = decoded as? [String:String] {
 let str = dictFromJSON.map { "\($0)=\($1)" }.joined(separator: "&")
 let postData =  str.data(using: .utf8)
 request.httpBody = postData
 }
 } catch {
 print(error.localizedDescription)
 }
 */
