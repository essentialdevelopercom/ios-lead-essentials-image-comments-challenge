//
//  Created by Azamat Valitov on 20.03.2021.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import Foundation

public struct FeedCommentsViewModel {
	public let comments: [FeedCommentViewModel]
	
	public init(comments: [FeedCommentViewModel]) {
		self.comments = comments
	}
}

public struct FeedCommentViewModel {
	public let name: String
	public let message: String
	public let formattedDate: String
	
	public init(name: String, message: String, formattedDate: String) {
		self.name = name
		self.message = message
		self.formattedDate = formattedDate
	}
}
