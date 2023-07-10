//
//  Main.swift
//  github-action-app
//
//  Created by Nikita Gorbunov on 03.07.2023.
//

import Foundation

@main
struct Main {
    static func main() async {
        let logger: Logger = .init(subject: "Main")
        let environment: Environment = ProcessInfo.processInfo.environment

        guard let inputData: InputData = .init(environment: environment),
              let triggerEvent: TriggerEvent = .init(rawValue: inputData.githubEventName) else {
            logger.failure("Failed to receive input data or unknown trigger: \(environment)")
            return
        }

        switch triggerEvent {
        case .createPullRequest:
            await PRNotificationAction().run(with: inputData)
        case .schedule, .manual:
            await RemindToCheckPRListAction().run(with: inputData)
        }
    }
}
