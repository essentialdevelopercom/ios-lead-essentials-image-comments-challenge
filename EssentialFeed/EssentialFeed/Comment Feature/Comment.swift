//
//  Comment.swift
//  EssentialFeed
//
//  Created by Eric Garlock on 3/1/21.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import Foundation

public struct Comment {
	public let id: UUID
	public let message: String
	public let created_at: Date
	public let author: CommentAuthor
}
