//
//  FeedImageComment+TestHelpers.swift
//  EssentialAppTests
//
//  Created by Ivan Ornes on 5/4/21.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import Foundation
import EssentialFeed

extension FeedImageComment {
	var formattedDate: String {
		let formatter = RelativeDateTimeFormatter()
		return formatter.localizedString(for: createdAt, relativeTo: Date())
	}
}
