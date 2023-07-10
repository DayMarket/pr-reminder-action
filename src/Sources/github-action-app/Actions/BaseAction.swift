//
//  BaseAction.swift
//  github-action-app
//
//  Created by Nikita Gorbunov on 03.07.2023.
//

import Foundation

class BaseAction {
    var logger: Logger
    
    init() {
        self.logger = .init(subject: "\(Self.self)")
    }
    
    func run(with inputData: InputData) async {
        ///override
    }
}
