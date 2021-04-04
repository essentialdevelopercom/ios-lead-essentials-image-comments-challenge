//
//  WeakRefVirtualProxy.swift
//  EssentialFeediOS
//
//  Created by Sebastian Vidrea on 03.04.2021.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import Foundation
import EssentialFeed

final class WeakRefVirtualProxy<T: AnyObject> {
	private weak var object: T?

	init(_ object: T) {
		self.object = object
	}
}

extension WeakRefVirtualProxy: ImageCommentsLoadingView where T: ImageCommentsLoadingView {
	func display(_ viewModel: ImageCommentsLoadingViewModel) {
		object?.display(viewModel)
	}
}

extension WeakRefVirtualProxy: ImageCommentsErrorView where T: ImageCommentsErrorView {
	func display(_ viewModel: ImageCommentsErrorViewModel) {
		object?.display(viewModel)
	}
}

extension WeakRefVirtualProxy: ImageCommentView where T: ImageCommentView {
	func display(_ viewModel: ImageCommentViewModel) {
		object?.display(viewModel)
	}
}
