//
//  BaseAPIClient.swift
//  github-action-app
//
//  Created by Nikita Gorbunov on 03.07.2023.
//

import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

class BaseAPIClient {
    // MARK: - Properties
    let logger: Logger
    
    // MARK: - Init
    init(logger: Logger) {
        self.logger = logger
    }
    
    // MARK: - Public methods
    func perform(_ request: Request) async throws {
       try await performDataTask(with: request)
    }
    
    func perform<T: Decodable>(_ request: Request, withResponse: T.Type) async throws -> T {
        let data: Data = try await performDataTask(with: request)
        do {
            return try JSONDecoder().decode(T.self, from: data)
        } catch {
            logger.info("Error decoding data\n\(getRequestDetails(request))\nError:\n\(error)", level: .verbose)
            throw APIError.decodingDataFailed
        }
    }
        
    // MARK: - Private methods
    @discardableResult
    private func performDataTask(with request: Request) async throws -> Data {
        let requestDetails: String = getRequestDetails(request)
        do {
            let (data, _) = try await URLSession.shared.data(from: request.asURLRequest())
            logger.success("Response was received\n\(requestDetails)")
            logger.info("\(getResponseDetails(from: data))", level: .verbose)
            return data
        } catch {
            logger.failure("Error was received\n\(requestDetails)\nError: \(error)")
            throw error
        }
        
    }
    private func getRequestDetails(_ request: Request) -> String {
        let request: URLRequest = request.asURLRequest()
        let url: String = request.url.map { "URL: \($0.absoluteString)" } ?? ""
        let body: String = request.httpBody.map { "\nBody: \(String(data: $0, encoding: .utf8) ?? "")" } ?? ""
        return url + body
    }
    private func getResponseDetails(from data: Data) -> String {
        String(data: data, encoding: .utf8).map { "Response: \($0)" } ?? ""
    }
}
