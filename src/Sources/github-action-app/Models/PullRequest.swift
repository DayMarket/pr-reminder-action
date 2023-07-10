//
//  PullRequest.swift
//  github-action-app
//
//  Created by Nikita Gorbunov on 03.07.2023.
//

import Foundation

struct PullRequest {
    typealias GetPullRequestResponse = GithubAPIClient.GetPullRequestResponse
    typealias GetReviewsResponse = GithubAPIClient.GetReviewsResponse
    
    // MARK: - Properties
    let number: String
    let title: String
    let url: String
    var author: User
    var reviews: [Review]
    
    // MARK: - Init
    init?(pullRequest: GetPullRequestResponse) {
        guard pullRequest.reviewers?.isEmpty == false,
              let numberInt: Int = pullRequest.number,
              let title: String = pullRequest.title,
              let url: String = pullRequest.url,
              let author: User = .init(response: pullRequest.user) else {
            return nil
        }
        
        let waitingReviews: [Review] = pullRequest.reviewers?.compactMap {
            guard let user: User = .init(response: $0) else { return nil }
            return .init(user: user, state: .waiting)
        } ?? []
                
        self.number = String(numberInt)
        self.title = title
        self.url = url
        self.author = author
        self.reviews = waitingReviews
    }
    
    mutating func tryToFillSlackName(with slackUsers: [SlackUser]) {
        for user in slackUsers {
            if user.githubProfile == author.login {
                author.slackUser = user.id
            } else if let index: Int = reviews.firstIndex(where: { $0.user.login == user.githubProfile }) {
                reviews[index].user.slackUser = user.id
            }
        }
    }
}

// MARK: - User
extension PullRequest {
    struct User: Hashable {
        let id: Int
        let login: String
        var slackUser: String?
        var mentionName: String { slackUser.map { "<@\($0)>"} ?? login }
        
        init?(response: GetReviewsResponse.User?) {
            guard let id: Int = response?.id,
                  let login: String = response?.login else {
                return nil
            }
            
            self.login = login
            self.id = id
        }
        
        static func == (lhs: PullRequest.User, rhs: PullRequest.User) -> Bool {
            lhs.id == rhs.id && lhs.login == rhs.login && lhs.slackUser == rhs.slackUser
        }
    }
}

// MARK: - Review
extension PullRequest {
    struct Review: Hashable {
        var user: User
        let state: State
        
        init?(response: GetReviewsResponse) {
            guard let user: User = .init(response: response.user),
                  let state: State = .init(response: response.reviewState) else {
                return nil
            }
            
            self.init(user: user, state: state)
        }
        
        init(user: User, state: State) {
            self.user = user
            self.state = state
        }
        
        static func == (lhs: PullRequest.Review, rhs: PullRequest.Review) -> Bool {
            lhs.user == rhs.user
        }
    }
}

extension PullRequest.Review {
    typealias GetReviewsResponse = PullRequest.GetReviewsResponse
    enum State {
        case approved, commented, waiting
        
        init?(response: GetReviewsResponse.ReviewState?) {
            guard let state: GetReviewsResponse.ReviewState = response else {
                return nil
            }

            switch state {
            case .approved:
                self = .approved
            case .commented:
                self = .commented
            }
        }
    }
}
