//
//  Copyright © 2019 Essential Developer. All rights reserved.
//

import UIKit
import EssentialFeed
import EssentialFeediOS

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

extension WeakRefVirtualProxy: FeedCommentsView where T: FeedCommentsView {
	func display(_ viewModel: FeedCommentsViewModel) {
		object?.display(viewModel)
	}
}

extension WeakRefVirtualProxy: FeedCommentsLoadingView where T: FeedCommentsLoadingView {
	func display(_ viewModel: FeedCommentsLoadingViewModel) {
		object?.display(viewModel)
	}
}

extension WeakRefVirtualProxy: FeedCommentsErrorView where T: FeedCommentsErrorView {
	func display(_ viewModel: FeedCommentsErrorViewModel) {
		object?.display(viewModel)
	}
}
