//
//  Blocks.swift
//  github-action-app
//
//  Created by Nikita Gorbunov on 05.07.2023.
//

import Foundation

final class Blocks {
    private var content: [Content] = []

    @discardableResult
    func header(_ text: String) -> Self {
        content.append(Content.header(text))
        return self
    }
    
    @discardableResult
    func divider() -> Self {
        content.append(Content.divider)
        return self
    }
    
    @discardableResult
    func sectionText(_ text: String) -> Self {
        content.append(Content.sectionText(text))
        return self
    }
    
    @discardableResult
    func sectionFields(_ fields: [String]) -> Self {
        content.append(Content.fields(fields))
        return self
    }
    
    func build() -> String {
        "[\(content.map { $0.string }.joined(separator: ","))]"
    }
}
