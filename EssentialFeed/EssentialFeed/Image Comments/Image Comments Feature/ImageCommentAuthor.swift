//
//  ImageCommentAuthor.swift
//  EssentialFeed
//
//  Created by Lukas Bahrle Santana on 20/01/2021.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import Foundation

public struct ImageCommentAuthor: Hashable {
	public let username: String
	
	public init(username: String){
		self.username = username
	}
}
