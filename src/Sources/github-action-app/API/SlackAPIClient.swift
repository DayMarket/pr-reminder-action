//
//  SlackAPIClient.swift
//  github-action-app
//
//  Created by Nikita Gorbunov on 03.07.2023.
//

import Foundation

final class SlackAPIClient: BaseAPIClient {
    // MARK: - Properties
    private let host: String
    private let token: String
    private var headers: Request.Headers {
        [
            "Authorization": "Bearer \(token)",
            "Content-Type": "application/json"
        ]
    }
    // MARK: - Init
    init(host: String = "https://slack.com",
         token: String,
         logger: Logger) {
        self.host = host
        self.token = token
        super.init(logger: logger)
    }
    
    // MARK: - Public methods
    func postMessage(_ message: String, to chatID: String) async throws {
        let parameters: [Request.Parameters] = [
            .init(context: .body, dictionary: ["channel": chatID, "blocks": message])
        ]
        let request: Request = .init(
            host: host,
            path: "/api/chat.postMessage",
            method: .post,
            headers: headers,
            parameters: parameters
        )
        
        try await perform(request)
    }
    
    func getUsers(from groupID: String, withGithubField fieldId: String) async throws -> [SlackUser] {
        let getUsersIdListResponse: GetUsersIdListResponse = try await getUserIdList(inUserGroup: groupID)
        guard let usersIdList: [String] = getUsersIdListResponse.users else { return [] }
        var users: [SlackUser] = []
        for userId in usersIdList {
            let response: GetUserProfileResponse = try await getUser(byID: userId)
            if let user: SlackUser = .init(id: userId, githubFieldId: fieldId, response: response) {
                users.append(user)
            }
        }
        return users
    }
    
    // MARK: - Private methods
    private func getUserIdList(inUserGroup groupID: String) async throws -> GetUsersIdListResponse {
        let parameters: [Request.Parameters] = [
            .init(context: .url, dictionary: ["usergroup": groupID])
        ]
        let request: Request = .init(
            host: host,
            path: "/api/usergroups.users.list",
            method: .get,
            headers: headers,
            parameters: parameters
        )
        
        return try await perform(request, withResponse: GetUsersIdListResponse.self)
    }
    
    private func getUser(byID userID: String) async throws -> GetUserProfileResponse {
        let parameters: [Request.Parameters] = [
            .init(context: .url, dictionary: ["user": userID])
        ]
        let request: Request = .init(
            host: host,
            path: "/api/users.profile.get",
            method: .get,
            headers: headers,
            parameters: parameters
        )
        
        return try await perform(request, withResponse: GetUserProfileResponse.self)
    }
}


// MARK: - GetUsersListResponse
extension SlackAPIClient {
    struct GetUsersIdListResponse: Decodable {
        let users: [String]?
    }
}

// MARK: - GetUsersProfileResponse
extension SlackAPIClient {
    struct GetUserProfileResponse: Decodable {
        let profile: SlackProfile?
    }
}

extension SlackAPIClient.GetUserProfileResponse {
    struct SlackProfile: Decodable {
        let displayName: String?
        let fields: [String: Field]?
        
        enum CodingKeys: String, CodingKey {
            case displayName = "display_name"
            case fields
        }
    }
    
    struct Field: Decodable {
        let value: String?
    }
}
