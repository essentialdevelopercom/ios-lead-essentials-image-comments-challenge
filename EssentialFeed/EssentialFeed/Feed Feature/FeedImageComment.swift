//
//  FeedImageComment.swift
//  EssentialFeed
//
//  Created by Mario Alberto Barragán Espinosa on 04/02/21.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import Foundation

public struct FeedImageComment: Equatable {
	let id: UUID
	let message: String
	let creationDate: Date
	let author: CommentAuthor
	
	struct CommentAuthor: Equatable {
		let username: String
	}
}
