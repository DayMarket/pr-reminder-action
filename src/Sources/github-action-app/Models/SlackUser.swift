//
//  SlackUser.swift
//  github-action-app
//
//  Created by Nikita Gorbunov on 03.07.2023.
//

import Foundation

struct SlackUser {
    let id: String
    let githubProfile: String
    
    init?(id: String,
          githubFieldId: String,
          response: SlackAPIClient.GetUserProfileResponse) {
        guard let githubProfile: String = response.profile?.fields?[githubFieldId]?.value else {
            return nil
        }
        self.id = id
        self.githubProfile = githubProfile
    }
}
