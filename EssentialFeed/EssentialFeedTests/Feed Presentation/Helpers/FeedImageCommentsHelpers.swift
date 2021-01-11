//
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import Foundation
import EssentialFeed

private func uniqueImageComments() -> [FeedImageComment] {
    return [
        FeedImageComment(id: UUID(), message: "a message", createdAt: anyDate(), author: "a username"),
        FeedImageComment(id: UUID(), message: "another message", createdAt: anyDate(), author: "another username")
    ]
}

private func anyDate() -> Date {
    Date(timeIntervalSince1970: 1603416829)
}
