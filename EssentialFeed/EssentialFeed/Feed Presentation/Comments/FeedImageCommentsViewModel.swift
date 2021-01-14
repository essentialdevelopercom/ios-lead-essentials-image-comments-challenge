//
//  Copyright © 2021 Essential Developer. All rights reserved.
//

public struct FeedImageCommentPresenterModel: Hashable {
    public let username: String
    public let creationTime: String
    public let comment: String
    
    public init(username: String, creationTime: String, comment: String) {
        self.username = username
        self.creationTime = creationTime
        self.comment = comment
    }
}

public struct FeedImageCommentsViewModel {
    public let comments: [FeedImageCommentPresenterModel]
    
    public init(comments: [FeedImageCommentPresenterModel]) {
        self.comments = comments
    }
}
