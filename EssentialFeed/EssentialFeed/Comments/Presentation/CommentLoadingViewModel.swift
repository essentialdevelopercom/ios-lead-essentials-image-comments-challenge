//
//  CommentLoadingViewModel.swift
//  EssentialFeed
//
//  Created by Robert Dates on 1/23/21.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import Foundation

public protocol CommentLoadingView {
	func display(_ viewModel: CommentLoadingViewModel)
}

public struct CommentLoadingViewModel {
	public let isLoading: Bool
}
