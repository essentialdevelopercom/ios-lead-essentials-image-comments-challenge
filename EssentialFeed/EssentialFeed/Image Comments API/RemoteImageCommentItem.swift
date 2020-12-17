//
//  RemoteImageCommentItem.swift
//  EssentialFeed
//
//  Created by Cronay on 17.12.20.
//  Copyright © 2020 Essential Developer. All rights reserved.
//

import Foundation

struct RemoteImageCommentItem: Decodable {
	let id: UUID
	let message: String
	let created_at: Date
	let author: RemoteImageCommentAuthorItem
}
