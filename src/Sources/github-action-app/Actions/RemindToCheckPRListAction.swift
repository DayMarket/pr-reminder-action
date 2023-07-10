//
//  RemindToCheckPRListAction.swift
//  github-action-app
//
//  Created by Nikita Gorbunov on 03.07.2023.
//

import Foundation

final class RemindToCheckPRListAction: BaseAction {
    override func run(with inputData: InputData) async {
        let githubAPIClient: GithubAPIClient = .init(token: inputData.githubToken, repo: inputData.githubRepository, logger: logger)
        let slackAPIClient: SlackAPIClient = .init(token: inputData.slackBotAuthToken, logger: logger)

        do {
            let slackUsers: [SlackUser] = try await slackAPIClient.getUsers(from: inputData.slackUserGroupId, withGithubField: inputData.slackFieldId)
            let pullRequestsList: [PullRequest] = try await githubAPIClient.getPullRequestsList()
            let message: String = configureMessage(with: pullRequestsList, slackUsers: slackUsers)
            try await slackAPIClient.postMessage(message, to: inputData.slackChannelId)

            logger.success("Remind sent successfully")
        } catch {
            logger.failure("Failed to send remind\nError:\(error)")
        }
    }
    
    private func configureMessage(with pullRequestList: [PullRequest], slackUsers: [SlackUser]) -> String {
        let blocks: Blocks = .init()
        for var pullRequest in pullRequestList {
            pullRequest.tryToFillSlackName(with: slackUsers)
            let title: String = "*PR <\(pullRequest.url) | #\(pullRequest.number)> is waiting review from:*\n"
            let reviewers: String = pullRequest.reviews.map { $0.user.mentionName}.joined(separator: "\n")
            blocks
                .sectionText(title + reviewers)
                .divider()
        }
        return blocks.build()
    }
    
}
