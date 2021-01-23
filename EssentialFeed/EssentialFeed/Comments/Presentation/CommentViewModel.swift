//
//  CommentViewModel.swift
//  EssentialFeed
//
//  Created by Robert Dates on 1/23/21.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import Foundation

public protocol CommentView {
	func display(_ viewModel: CommentViewModel)
}

public struct CommentViewModel {
	public let comments: [Comment]
}
