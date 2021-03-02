//
//  RemoteCommentItem.swift
//  EssentialFeed
//
//  Created by Robert Dates on 1/21/21.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import Foundation

internal struct RemoteCommentItem: Decodable {
	let id: UUID
	let message: String
	let created_at: Date
	let author: RemoteAuthor
}

