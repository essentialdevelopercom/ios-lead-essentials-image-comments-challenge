//
//  ImageCommentsViewModel.swift
//  EssentialFeed
//
//  Created by Lukas Bahrle Santana on 25/01/2021.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import Foundation

public struct ImageCommentsViewModel{
	public let imageComments: [PresentableImageComment]
}


public struct PresentableImageComment: Hashable{
	let message: String
	let createdAt: String
	let username: String
	
	public init(message: String, createdAt: String, username: String) {
		self.message = message
		self.createdAt = createdAt
		self.username = username
	}
}
