//
//  GithubAPIClient.swift
//  github-action-app
//
//  Created by Nikita Gorbunov on 03.07.2023.
//

import Foundation

final class GithubAPIClient: BaseAPIClient {
    // MARK: - Properties
    private let host: String
    private let token: String
    private let apiVersion: String
    private let repo: String
    private var headers: Request.Headers {
        [
            "Authorization": "Bearer \(token)",
            "Accept": "application/vnd.github+json",
            "X-GitHub-Api-Version": "\(apiVersion)"
        ]
    }
    
    // MARK: - Init
    init(host: String = "https://api.github.com",
         token: String,
         apiVersion: String = "2022-11-28",
         repo: String,
         logger: Logger) {
        self.host = host
        self.token = token
        self.apiVersion = apiVersion
        self.repo = repo
        super.init(logger: logger)
    }
    
    // MARK: - Public methods
    func getPullRequestsList() async throws -> [PullRequest] {
        let request: Request = .init(
            host: host,
            path: "/repos/\(repo)/pulls",
            method: .get,
            headers: headers
        )
        
        let response = try await perform(request, withResponse: [GetPullRequestResponse].self)
        
        return response.compactMap { .init(pullRequest: $0) }
    }
        
    func getPullRequest(by pullRequestNumber: String) async throws -> PullRequest {
        let request: Request = .init(
            host: host,
            path: "/repos/\(repo)/pulls/\(pullRequestNumber)",
            method: .get,
            headers: headers
        )
        
        let response = try await perform(request, withResponse: GetPullRequestResponse.self)
        
        if let pullRequest: PullRequest = .init(pullRequest: response) {
            return pullRequest
        } else {
            throw APIError.responseMappingError
        }
    }
    
    // MARK: - Private methods
    private func getReviews(for pullRequestNumber: String?) async throws -> [GetReviewsResponse] {
        guard let pullRequestNumber: String else { throw APIError.missingRequiredParameters }
        let request: Request = .init(
            host: host,
            path: "/repos/\(repo)/pulls/\(pullRequestNumber)/reviews",
            method: .get,
            headers: headers
        )
        
        return try await perform(request, withResponse: [GetReviewsResponse].self)
    }
}

// MARK: - GetPullRequestInfoResponse
extension GithubAPIClient {
    struct GetPullRequestResponse: Decodable {
        let number: Int?
        let title: String?
        let url: String?
        let user: User?
        let reviewers: [User]?
        
        enum CodingKeys: String, CodingKey {
            case number, title, user
            case url = "html_url"
            case reviewers = "requested_reviewers"
        }
    }
}

extension GithubAPIClient.GetPullRequestResponse {
    struct User: Decodable {
        let id: Int?
        let login: String?
    }
}

// MARK: - GetReviewsResponse
extension GithubAPIClient {
    struct GetReviewsResponse: Decodable {
        typealias User = GetPullRequestResponse.User
        let user: User?
        let state: String?
        var reviewState: ReviewState? { state.map(ReviewState.init) ?? nil }
    }
}

extension GithubAPIClient.GetReviewsResponse {
    enum ReviewState: String {
        case approved = "APPROVED"
        case commented = "COMMENTED"
    }
}
