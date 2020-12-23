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

extension WeakRefVirtualProxy: ImageCommentsErrorView where T: ImageCommentsErrorView {
	func display(_ viewModel: ImageCommentsErrorViewModel) {
		object?.display(viewModel)
	}
}

extension WeakRefVirtualProxy: ImageCommentsLoadingView where T: ImageCommentsLoadingView {
	func display(_ viewModel: ImageCommentsLoadingViewModel) {
		object?.display(viewModel)
	}
}

extension WeakRefVirtualProxy: ImageCommentsView where T: ImageCommentsView {
	func display(_ model: ImageCommentsViewModel) {
		object?.display(model)
	}
}

