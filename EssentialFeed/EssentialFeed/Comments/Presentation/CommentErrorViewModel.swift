//
//  CommentErrorViewModel.swift
//  EssentialFeed
//
//  Created by Robert Dates on 1/23/21.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import Foundation

public protocol CommentErrorView {
	func display(_ viewModel: CommentErrorViewModel)
}

public struct CommentErrorViewModel {
	
	public let message: String?

	static var noError: CommentErrorViewModel {
		return CommentErrorViewModel(message: nil)
	}
	
	static func error(message: String) -> CommentErrorViewModel {
		return CommentErrorViewModel(message: message)
	}
}
