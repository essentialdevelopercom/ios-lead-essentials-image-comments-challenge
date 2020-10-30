//
//  Copyright © 2020 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import Foundation

public enum EssentialFeedEndpoint {
    public typealias ImageUUID = String

    case feed
    case comments(for: ImageUUID)

    public func url() -> URL {
        switch self {
        case .feed:
            return URL(string: "https://ile-api.essentialdeveloper.com/essential-feed/v1/feed")!
        case let .comments(uuid):
            return URL(string: "https://ile-api.essentialdeveloper.com/essential-feed/v1/image/\(uuid)/comments")!
        }
    }
}
