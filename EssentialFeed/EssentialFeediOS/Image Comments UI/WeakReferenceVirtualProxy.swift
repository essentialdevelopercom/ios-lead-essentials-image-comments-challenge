//
//  WeakReferenceVirtualProxy.swift
//  EssentialFeediOS
//
//  Created by Ángel Vázquez on 23/03/21.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

final class WeakReferenceVirtualProxy<T: AnyObject> {
	private weak var object: T?
	
	init(_ object: T) {
		self.object = object
	}
}

extension WeakReferenceVirtualProxy: ImageCommentLoadingView where T: ImageCommentLoadingView {
	func display(_ viewModel: ImageCommentLoadingViewModel) {
		object?.display(viewModel)
	}
}

extension WeakReferenceVirtualProxy: ImageCommentErrorView where T: ImageCommentErrorView {
	func display(_ viewModel: ImageCommentErrorViewModel) {
		object?.display(viewModel)
	}
}

extension WeakReferenceVirtualProxy: ImageCommentView where T: ImageCommentView {
	func display(_ viewModel: ImageCommentViewModel) {
		object?.display(viewModel)
	}
}
