//
//  ImageComment.swift
//  EssentialFeed
//
//  Created by Bogdan Poplauschi on 27/03/2021.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import Foundation

public struct ImageComment {
	public let id: UUID
	public let message: String
	public let createdAt: Date
	public let author: ImageCommentAuthor
}
