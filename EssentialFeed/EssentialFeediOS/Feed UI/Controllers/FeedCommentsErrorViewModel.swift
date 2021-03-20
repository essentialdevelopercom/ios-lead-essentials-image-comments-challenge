//
//  Created by Azamat Valitov on 20.03.2021.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import Foundation

public struct FeedCommentsErrorViewModel {
	public let message: String?
	
	static var noError: FeedCommentsErrorViewModel {
		return FeedCommentsErrorViewModel(message: nil)
	}
	
	public static func error(message: String) -> FeedCommentsErrorViewModel {
		return FeedCommentsErrorViewModel(message: message)
	}
}
