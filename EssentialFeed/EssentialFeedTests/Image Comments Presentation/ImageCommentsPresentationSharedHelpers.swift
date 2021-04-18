//
//  SharedHelpers.swift
//  EssentialFeedTests
//
//  Created by Ángel Vázquez on 27/03/21.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import EssentialFeed
import Foundation

func comment(date: Date) -> ImageComment {
	ImageComment(
		id: UUID(),
		message: "any message",
		creationDate: date,
		author: "any author"
	)
}
