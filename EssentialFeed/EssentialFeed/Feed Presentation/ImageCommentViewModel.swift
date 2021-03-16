//
//  ImageCommentViewModel.swift
//  EssentialFeed
//
//  Created by Adrian Szymanowski on 16/03/2021.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import Foundation

public struct ImageCommentViewModel {
	public let authorUsername: String
	
	public init(authorUsername: String) {
		self.authorUsername = authorUsername
	}
}
