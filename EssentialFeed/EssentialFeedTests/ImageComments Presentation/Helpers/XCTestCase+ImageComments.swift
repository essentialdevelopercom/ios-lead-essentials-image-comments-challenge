//
//  XCTestCase+ImageComments.swift
//  EssentialFeedTests
//
//  Created by Sebastian Vidrea on 04.04.2021.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import XCTest
import EssentialFeed

extension XCTestCase {

	func uniqueImageComment() -> ImageComment {
		ImageComment(id: UUID(), message: "a message", createdAt: Date(), author: ImageCommentAuthor(username: "a username"))
	}

	func uniqueImageComments() -> [ImageComment] {
		[uniqueImageComment(), uniqueImageComment()]
	}

}
