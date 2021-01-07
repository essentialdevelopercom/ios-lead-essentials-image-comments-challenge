//
//  CommentViewModel.swift
//  EssentialFeed
//
//  Created by Khoi Nguyen on 29/12/20.
//  Copyright © 2020 Essential Developer. All rights reserved.
//

import Foundation

public struct CommentViewModel {
	private let comments: [Comment]
	
	public var presentableComments: [PresentableComment] {
		return comments.map {
			return PresentableComment(
				message: $0.message,
				createAt: RelativeTimestampGenerator.generateTimestamp(with: $0.createAt),
				author: $0.author.username)
		}
	}
	public init(comments: [Comment]) {
		self.comments = comments
	}
}
