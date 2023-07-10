//
//  APIError.swift
//  github-action-app
//
//  Created by Nikita Gorbunov on 03.07.2023.
//

import Foundation

enum APIError: Error {
    case invalidURLResponse
    case missingResponseData
    case decodingDataFailed
    case invalidJSONObject
    case responseMappingError
    case missingRequiredParameters
}
