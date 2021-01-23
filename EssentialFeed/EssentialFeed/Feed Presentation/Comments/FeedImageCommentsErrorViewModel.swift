//
//  Copyright © 2021 Essential Developer. All rights reserved.
//

public struct FeedImageCommentsErrorViewModel {
    public let message: String?

    static var noError: FeedImageCommentsErrorViewModel {
        return FeedImageCommentsErrorViewModel(message: nil)
    }

    static func error(message: String) -> FeedImageCommentsErrorViewModel {
        return FeedImageCommentsErrorViewModel(message: message)
    }
}
