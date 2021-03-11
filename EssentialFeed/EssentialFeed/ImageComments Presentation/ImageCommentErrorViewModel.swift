//
//  ImageCommentErrorViewModel.swift
//  EssentialFeed
//
//  Created by Eric Garlock on 3/10/21.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

public struct ImageCommentErrorViewModel {
	public let message: String?
	
	static var clear: ImageCommentErrorViewModel {
		return ImageCommentErrorViewModel(message: nil)
	}
	
	public init(message: String?) {
		self.message = message
	}
}
