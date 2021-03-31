//
//  ImageCommentsViewModel.swift
//  EssentialFeed
//
//  Created by Lukas Bahrle Santana on 25/01/2021.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import Foundation

public struct ImageCommentsViewModel {
	public let imageComments: [PresentableImageComment]
	
	public init(imageComments: [PresentableImageComment]) {
		self.imageComments = imageComments
	}
}

public struct PresentableImageComment: Hashable {
	public let message: String
	public let createdAt: String
	public let username: String
	
	public init(message: String, createdAt: String, username: String) {
		self.message = message
		self.createdAt = createdAt
		self.username = username
	}
}
