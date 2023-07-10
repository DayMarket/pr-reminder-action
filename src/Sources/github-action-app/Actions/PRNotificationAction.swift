//
//  PRNotificationAction.swift
//  github-action-app
//
//  Created by Nikita Gorbunov on 03.07.2023.
//

import Foundation

final class PRNotificationAction: BaseAction {
    override func run(with inputData: InputData) async {
        let githubAPIClient: GithubAPIClient = .init(token: inputData.githubToken, repo: inputData.githubRepository, logger: logger)
        let slackAPIClient: SlackAPIClient = SlackAPIClient(token: inputData.slackBotAuthToken, logger: logger)

        do {
            guard let prNumber: String = inputData.githubPullRequestNumber else {
                logger.failure("Couldn't get a pull request number")
                return
            }

            let slackUsers: [SlackUser] = try await slackAPIClient.getUsers(from: inputData.slackUserGroupId, withGithubField: inputData.slackFieldId)
            var pullRequest: PullRequest = try await githubAPIClient.getPullRequest(by: prNumber)
            
            pullRequest.tryToFillSlackName(with: slackUsers)
            let message: String = configureMessage(with: pullRequest)
            
            try await slackAPIClient.postMessage(message, to: inputData.slackChannelId)

            logger.success("Notification sent successfully")
        } catch {
            logger.failure("Failed to send notification\nError:\(error)")
        }
    }
   
    private func configureMessage(with pullRequest: PullRequest) -> String {
        Blocks()
            .sectionText("*PR #\(pullRequest.number) was created:*\n<\(pullRequest.url)|\(pullRequest.title)>")
            .sectionFields([
                "*Reviewers*:\n\(pullRequest.reviews.map { $0.user.mentionName }.joined(separator: "\n"))",
                "*Author:*\n\(pullRequest.author.mentionName)"
            ])
            .divider()
            .build()
    }
}
