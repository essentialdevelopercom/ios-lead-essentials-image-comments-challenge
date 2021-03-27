//
//  RemoteImageComment.swift
//  EssentialFeed
//
//  Created by Sebastian Vidrea on 27.03.2021.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import Foundation

struct RemoteImageComment: Decodable {
	let id: UUID
	let message: String
	let createdAt: Date
	let author: RemoteImageCommentAuthor
}
