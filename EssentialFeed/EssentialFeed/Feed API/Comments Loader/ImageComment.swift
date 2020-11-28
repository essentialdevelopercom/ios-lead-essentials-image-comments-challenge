//
//  ImageComment.swift
//  EssentialFeed
//
//  Created by Maxim Soldatov on 11/28/20.
//  Copyright © 2020 Essential Developer. All rights reserved.
//
import Foundation

public struct ImageComment: Equatable {
	
	let id: UUID
	let message: String
	let createdAt: Date
	let author: String
	
	public init(id: UUID, message: String, createdAt: Date, author: String) {
		self.id = id
		self.message = message
		self.createdAt = createdAt
		self.author = author
	}
}
