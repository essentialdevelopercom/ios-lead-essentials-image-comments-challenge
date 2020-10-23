//
//  Copyright © 2020 Essential Developer. All rights reserved.
//

import Foundation

public struct ImageComment: Hashable {
    let id: UUID
    let message: String
    let createdAt: Date
    let author: String

    public init(id: UUID, message: String, createdAt: Date, author: String) {
        self.id = id
        self.message = message
        self.createdAt = createdAt
        self.author = author
    }
}
