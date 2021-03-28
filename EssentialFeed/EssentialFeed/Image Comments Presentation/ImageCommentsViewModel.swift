//
//  ImageCommentsViewModel.swift
//  EssentialFeed
//
//  Created by Bogdan Poplauschi on 28/03/2021.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import Foundation

public struct PresentableImageComment: Equatable {
	let createdAt: String
	let message: String
	let author: String
	
	public init(createdAt: String, message: String, author: String) {
		self.createdAt = createdAt
		self.message = message
		self.author = author
	}
}

public struct ImageCommentsViewModel {
	public let comments: [PresentableImageComment]
}
