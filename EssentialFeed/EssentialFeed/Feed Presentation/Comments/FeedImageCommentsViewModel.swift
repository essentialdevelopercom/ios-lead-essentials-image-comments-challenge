//
//  Copyright © 2021 Essential Developer. All rights reserved.
//

public struct FeedImageCommentPresenterModel: Hashable {
    let username: String
    let creationTime: String
    let comment: String
}

public struct FeedImageCommentsViewModel {
    public let comments: [FeedImageCommentPresenterModel]
}
