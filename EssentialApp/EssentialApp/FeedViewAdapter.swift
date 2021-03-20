//
//  Copyright © 2019 Essential Developer. All rights reserved.
//

import UIKit
import EssentialFeed
import EssentialFeediOS

final class FeedViewAdapter: FeedView {
	private weak var controller: FeedViewController?
	private let onOpenComments: (UUID)->()
	private let imageLoader: (URL) -> FeedImageDataLoader.Publisher
	
	init(controller: FeedViewController, imageLoader: @escaping (URL) -> FeedImageDataLoader.Publisher, onOpenComments: @escaping (UUID)->()) {
		self.controller = controller
		self.imageLoader = imageLoader
		self.onOpenComments = onOpenComments
	}
	
	func display(_ viewModel: FeedViewModel) {
		controller?.display(viewModel.feed.map { model in
			let adapter = FeedImageDataLoaderPresentationAdapter<WeakRefVirtualProxy<FeedImageCellController>, UIImage>(model: model, imageLoader: imageLoader)
			let view = FeedImageCellController(delegate: adapter, onOpenComments: {[weak self] in
				self?.onOpenComments(model.id)
			})
			
			adapter.presenter = FeedImagePresenter(
				view: WeakRefVirtualProxy(view),
				imageTransformer: UIImage.init)
			
			return view
		})
	}
}
