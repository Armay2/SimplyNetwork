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
    public typealias DataRequestCompletion = (Result<(Data, URLResponse), Error>) -> Void
    public typealias CodableRequestCompletion<T: Codable> = (Result<(T, URLResponse), Error>) -> Void
    
    // MARK: - Request
    
    /// Return a `Data` object after prossesing an http request
    /// - Parameters:
    ///   - strUrl: The string `String` for the request
    ///   - method: The `HTTPMethod` for the request, default is `.get`
    ///   - parameters: The `Parameters` for the request
    ///   - headers: The `HTTPHeaders` for the request
    ///   - paramDestination: Destination for the parameters `ParamDestination`, default is `.methodDependent`
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
            }
            guard let response = response as? HTTPURLResponse else { return }
            if (200...299).contains(response.statusCode) || response.statusCode == 400 {
                if let data = data {
                    completion(.success((data, response)))
                } else {
                    completion(.failure(SimplyNetworkError.noDataFound))
                }
            } else {
                completion(.failure(self.errorFromStatusCode(for: response.statusCode)))
            }
        }
        dataTask.resume()
    }
    
    /// Return a `Codable` object after prossesing an http request
    /// - Parameters:
    ///   - strUrl: The url `String` for the request
    ///   - method: The `HTTPMethod` for the request, default is `.get`
    ///   - parameters: The `Parameters` for the request
    ///   - headers: The `HTTPHeaders` for the request
    ///   - paramDestination: Destination for the parameters `ParamDestination`, default is `.methodDependent`
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
                if (200...299).contains(response.statusCode) || response.statusCode == 400 {
                    DispatchQueue.main.async {
                        do {
                            let decodedJSON = try JSONDecoder().decode(T.self, from: data)
                            completion(.success((decodedJSON, response)))
                        } catch let error {
                            completion(.failure(error)) // SimpleNetworkError.decodingJSON ?
                        }
                    }
                } else {
                    completion(.failure(self.errorFromStatusCode(for: response.statusCode)))
                }
            }
        }
        dataTask.resume()
    }
    
    // MARK: - Upload
    
    /// Upload a file thanks to is `URL` to a targeted destination `URL`
    /// - Parameters:
    ///   - fileURL: `URL` of file you want to upload
    ///   - targetURL: Target `URL`
    ///   - completion: The callback called after retrieval
    open func uploadFile(fileURL: URL,
                         to targetURL: String,
                         completion: @escaping DataRequestCompletion) throws {
        guard let requestUrl = URL(string: targetURL) else {
            throw SimplyNetworkError.invalidURL
        }
        var request = URLRequest(url: requestUrl)
        request.httpMethod = "POST"
        request.setValue(HeaderContentType.JSON.rawValue, forHTTPHeaderField: "Content-Type")
        
        let task = URLSession.shared.uploadTask(with: request, fromFile: fileURL, completionHandler: { data, response, error in
            if let error = error {
                completion(.failure(error))
            }
            guard let response = response as? HTTPURLResponse else { return }
            if (200...299).contains(response.statusCode), let mimeType = response.mimeType, mimeType == "application/json",
               let data = data {
                completion(.success((data, response)))
            } else {
                completion(.failure(self.errorFromStatusCode(for: response.statusCode)))
            }
        }
        )
        task.resume()
    }
    
    
    /// Upload some given `Data` to a targeted `URL`
    /// - Parameters:
    ///   - dataToSend: The `Data` that you when to upload
    ///   - targetURL: Target `URL`
    ///   - completion: The callback called after retrieval
    open func uploadFile(dataToSend: Data,
                         to targetURL: String,
                         completion: @escaping DataRequestCompletion) throws {
        guard let requestUrl = URL(string: targetURL) else {
            throw SimplyNetworkError.invalidURL
        }
        var request = URLRequest(url: requestUrl)
        request.httpMethod = "POST"
        request.setValue(HeaderContentType.JSON.rawValue, forHTTPHeaderField: "Content-Type")
        
        let task = URLSession.shared.uploadTask(with: request, from: dataToSend, completionHandler: { data, response, error in
            if let error = error {
                completion(.failure(error))
            }
            guard let response = response as? HTTPURLResponse else { return }
            if (200...299).contains(response.statusCode), let mimeType = response.mimeType, mimeType == "application/json",
               let data = data {
                completion(.success((data, response)))
            } else {
                completion(.failure(self.errorFromStatusCode(for: response.statusCode)))
            }
        }
        )
        task.resume()
    }
    
    // MARK: - Setup
    
    /// Configures `URLRequest` for requests that need a specific `parameters` and `headers`
    /// - Parameters:
    ///   - strUrl: The url `String` for the request
    ///   - method: The `HTTPMethod` for the request
    ///   - parameters: The `Parameters` for the request
    ///   - headers: The `HTTPHeaders` for the request
    ///   - paramDestination: Destination for the parameters `ParamDestination`, default is `.methodDependent`
    private func configureURLRequest(for strUrl: String,
                                     method: HTTPMethod,
                                     parameters: Parameters?,
                                     headers: HTTPHeaders?,
                                     paramDestination: ParamDestination?) throws -> URLRequest {
        guard let requestUrl = URL(string: strUrl) else {
            throw SimplyNetworkError.invalidURL
        }
        var request = URLRequest(url: requestUrl)
        request.httpMethod = method.rawValue
        
        //Better way ?
        if var headers = headers {
            headers.forEach({ header in
                request.addValue(header.value, forHTTPHeaderField: header.name)
            })
            
            if paramDestination == .httpBody {
                if headers["Content-Type"] == nil {
                    headers.update(name: "Content-Type", value: HeaderContentType.formUrlencoded.rawValue)
                }
            }
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
            return SimplyNetworkError.unknowError(statusCode: statusCode)
        }
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
