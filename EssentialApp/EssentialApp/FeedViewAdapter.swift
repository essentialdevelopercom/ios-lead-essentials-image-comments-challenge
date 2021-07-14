//
//  Copyright © 2019 Essential Developer. All rights reserved.
//

import Combine
import UIKit
import EssentialFeed
import EssentialFeediOS

final class FeedViewAdapter: FeedView {
	private weak var controller: FeedViewController?
	private let imageLoader: (URL) -> AnyPublisher<Data, Error>
	private let onSelect: (FeedImage) -> Void
	
	init(controller: FeedViewController, imageLoader: @escaping (URL) -> AnyPublisher<Data, Error>, onSelect: @escaping (FeedImage) -> Void) {
		self.controller = controller
		self.imageLoader = imageLoader
		self.onSelect = onSelect
	}
	
	func display(_ viewModel: FeedViewModel) {
		controller?.display(viewModel.feed.map { model in
			let adapter = FeedImageDataLoaderPresentationAdapter<WeakRefVirtualProxy<FeedImageCellController>, UIImage>(model: model, imageLoader: imageLoader, onSelect: onSelect)
			let view = FeedImageCellController(delegate: adapter)
			
			adapter.presenter = FeedImagePresenter(
				view: WeakRefVirtualProxy(view),
				imageTransformer: UIImage.init)
			
			return view
		})
	}
}
