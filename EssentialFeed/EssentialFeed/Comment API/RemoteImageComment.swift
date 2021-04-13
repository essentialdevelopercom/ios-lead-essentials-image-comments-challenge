//
//  RemoteImageComment.swift
//  EssentialFeed
//
//  Created by Antonio Mayorga on 3/16/21.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import Foundation

public struct RemoteImageComment: Decodable {
	let id: UUID
	let message: String
	let created_at: String
	let author: ImageCommentAuthor
}
