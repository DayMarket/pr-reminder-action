//
//  BaseRequest.swift
//  github-action-app
//
//  Created by Nikita Gorbunov on 03.07.2023.
//

import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

final class Request {
    typealias Headers = [String: String]
    // MARK: - Properties
    private let host: String
    private var path: String
    private var method: HTTPMethod
    private var parameters: [Parameters]
    private var headers: Headers = [:]
    // MARK: - Init
    init(host: String,
         path: String,
         method: HTTPMethod,
         headers: Headers = [:],
         parameters: [Parameters] = []) {
        self.host = host
        self.path = path
        self.method = method
        self.parameters = parameters
        self.headers = headers
    }
    
    func asURLRequest() -> URLRequest {
        var components: URLComponents? = .init(string: host)
        components!.path = path
        let url: URL = components!.url!
        var request: URLRequest = .init(url: url)
        request.httpMethod = method.rawValue
        headers.forEach { request.addValue($0.value, forHTTPHeaderField: $0.key) }
        if !parameters.isEmpty {
            for parameter in parameters {
                switch parameter.context {
                case .body:
                    request.httpBody = try? parameter.asData()
                case .url:
                    components?.queryItems = parameter.asQueryItems()
                    request.url = components?.url
                case .plain:
                    continue
                }
            }
        }
        return request
    }
}

// MARK: - HTTPMethods
extension Request {
    enum HTTPMethod: String {
        case get = "GET"
        case post = "POST"
    }
}

// MARK: - Parameters
extension Request {
    struct Parameters {
        let context: Context
        private var dictionary: [String: Any] = [:]
        
        init(context: Context, dictionary: [String: Any] = [:]) {
            self.context = context
            self.dictionary = dictionary
        }
        
        func asData() throws -> Data {
            if !JSONSerialization.isValidJSONObject(dictionary) { throw APIError.invalidJSONObject }
            return try JSONSerialization.data(withJSONObject: dictionary, options: [])
        }
        
        func asQueryItems() -> [URLQueryItem] {
            dictionary.map { URLQueryItem(name: $0, value: "\($1)") }
        }
    }
}

extension Request.Parameters {
    enum Context {
        case url, body, plain
    }
}

