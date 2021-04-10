//
//  Created by Azamat Valitov on 13.03.2021.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import Foundation

public struct FeedComment: Equatable {
	public let id: UUID
	public let message: String
	public let date: Date
	public let authorName: String
	
	public init(id: UUID, message: String, date: Date, authorName: String) {
		self.id = id
		self.message = message
		self.date = date
		self.authorName = authorName
	}
}
