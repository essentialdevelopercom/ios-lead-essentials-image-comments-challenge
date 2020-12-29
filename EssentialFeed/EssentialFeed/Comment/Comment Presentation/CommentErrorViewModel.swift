//
//  CommentErrorViewModel.swift
//  EssentialFeed
//
//  Created by Khoi Nguyen on 29/12/20.
//  Copyright © 2020 Essential Developer. All rights reserved.
//

import Foundation

public struct CommentErrorViewModel {
	public let message: String?
	
	static var noError: CommentErrorViewModel {
		return CommentErrorViewModel(message: nil)
	}
	
	static func error(message: String) -> CommentErrorViewModel {
		return CommentErrorViewModel(message: message)
	}
}
