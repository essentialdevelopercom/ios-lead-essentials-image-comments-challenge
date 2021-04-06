//
//  Copyright © 2019 Essential Developer. All rights reserved.
//

import UIKit
import EssentialFeed

final class WeakRefVirtualProxy<T: AnyObject> {
	private weak var object: T?
	
	init(_ object: T) {
		self.object = object
	}
}

extension WeakRefVirtualProxy: FeedErrorView where T: FeedErrorView {
	func display(_ viewModel: FeedErrorViewModel) {
		object?.display(viewModel)
	}
}

extension WeakRefVirtualProxy: FeedLoadingView where T: FeedLoadingView {
	func display(_ viewModel: FeedLoadingViewModel) {
		object?.display(viewModel)
	}
}

extension WeakRefVirtualProxy: FeedImageView where T: FeedImageView, T.Image == UIImage {
	func display(_ model: FeedImageViewModel<UIImage>) {
		object?.display(model)
	}
}

extension WeakRefVirtualProxy: CommentErrorView where T: CommentErrorView {
	func display(_ viewModel: CommentErrorViewModel) {
		object?.display(viewModel)
	}
}

extension WeakRefVirtualProxy: CommentLoadingView where T: CommentLoadingView {
	func display(_ viewModel: CommentLoadingViewModel) {
		object?.display(viewModel)
	}
}

extension WeakRefVirtualProxy: CommentView where T: CommentView {
	func display(_ model: CommentViewModel) {
		object?.display(model)
	}
}
