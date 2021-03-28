//
//  RemoteImageComment.swift
//  EssentialFeed
//
//  Created by Bogdan Poplauschi on 28/03/2021.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import Foundation

struct RemoteImageComment: Decodable {
	let id: UUID
	let message: String
	let created_at: Date
	let author: RemoteImageCommentAuthor
}
