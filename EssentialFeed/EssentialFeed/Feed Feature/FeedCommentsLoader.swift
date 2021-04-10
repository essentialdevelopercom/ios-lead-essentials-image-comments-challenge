//
//  Created by Azamat Valitov on 13.03.2021.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import Foundation

public protocol FeedCommentsLoaderTask {
	func cancel()
}

public protocol FeedCommentsLoader {
	typealias Result = Swift.Result<[FeedComment], Error>

	func load(completion: @escaping (Result) -> Void) -> FeedCommentsLoaderTask
}
