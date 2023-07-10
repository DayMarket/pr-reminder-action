//
//  Logger.swift
//  github-action-app
//
//  Created by Nikita Gorbunov on 03.07.2023.
//

import Foundation

struct Logger {
    // MARK: - Properties
    private let subject: String
    private let level: LogLevel
    // MARK: - Init
    init(subject: String, level: LogLevel = .main) {
        self.subject = subject
        self.level = level
    }
    
    // MARK: - Public methods
    func failure(_ message: String, level: LogLevel = .main) {
        log(message: message, kind: .error, level: level)
    }
    
    func info(_ message: String, level: LogLevel = .main) {
        log(message: message, kind: .info, level: level)
    }
    
    func success(_ message: String, level: LogLevel = .main) {
        log(message: message, kind: .success, level: level)
    }
    
    // MARK: - Private methods
    private func log(message: String, kind: Kind, level: LogLevel) {
        guard level >= self.level else { return }
        let prefix: String
        switch kind {
        case .error: prefix = "⛔️[\(subject)] "
        case .info: prefix = "ℹ️[\(subject)] "
        case .success: prefix = "✅[\(subject)] "
        }
        let formattedMessage: String = message.replacingOccurrences(of: "\n", with: "\n\(prefix)")
        print(prefix + formattedMessage)
    }
}

// MARK: - Kind
extension Logger {
    enum Kind {
        case error
        case info
        case success
    }
}

// MARK: - LogLevel
extension Logger {
    public enum LogLevel: Comparable {
        case verbose, main
        
        fileprivate var priority: Int {
            switch self {
            case .verbose: return 0
            case .main: return 1
            }
        }
        static func < (lhs: Logger.LogLevel, rhs: Logger.LogLevel) -> Bool {
            lhs.priority < rhs.priority
        }
    }
}
