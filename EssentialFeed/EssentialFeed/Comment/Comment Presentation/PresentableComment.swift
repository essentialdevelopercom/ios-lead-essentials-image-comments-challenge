//
//  PresentableComment.swift
//  EssentialFeed
//
//  Created by Khoi Nguyen on 5/1/21.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import Foundation

public struct PresentableComment: Hashable {
	public init(message: String, createAt: String, author: String) {
		self.message = message
		self.createAt = createAt
		self.author = author
	}
	
	public let message: String
	public let createAt: String
	public let author: String
}
