//
//  Created by Azamat Valitov on 20.03.2021.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import Foundation

public struct FeedCommentsViewModel {
	public let comments: [FeedCommentViewModel]
}

public struct FeedCommentViewModel {
	public let name: String
	public let message: String
	public let formattedDate: String
}
