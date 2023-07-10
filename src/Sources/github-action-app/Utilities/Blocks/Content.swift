//
//  Constants.swift
//  github-action-app
//
//  Created by Nikita Gorbunov on 06.07.2023.
//

import Foundation

extension Blocks {
    enum Content {
        case divider
        case header(String)
        case sectionText(String)
        case fields([String])
        case mrkdwn(String)
        
        var string: String {
            switch self {
            case .divider: return
"""
{"type": "divider"}
"""
            case let .header(text): return
"""
{"type": "header", "text": {"type": "plain_text", "text": "\(text)", "emoji": true}}
"""
            case let .sectionText(text): return
"""
    {"type": "section", "text": \(Self.mrkdwn(text).string) }
"""
            case let .fields(fields):
                return
"""
    {"type": "section", "fields": [\(fields.map { Self.mrkdwn($0).string }.joined(separator: ","))] }
"""
            case let .mrkdwn(text): return
"""
{"type": "mrkdwn", "text": "\(text)"}
"""
            }
        }
    }
}
