//
//  Copyright © 2019 Essential Developer. All rights reserved.
//

import UIKit
import EssentialFeed
import EssentialFeediOS

final class FeedViewAdapter: FeedView {
	private weak var controller: FeedViewController?
	private let imageLoader: (URL) -> FeedImageDataLoader.Publisher
	private let didSelectFeedImage: (FeedImage) -> Void
	
	init(controller: FeedViewController, imageLoader: @escaping (URL) -> FeedImageDataLoader.Publisher, didSelectFeedImage: @escaping (FeedImage) -> Void) {
		self.controller = controller
		self.imageLoader = imageLoader
		self.didSelectFeedImage = didSelectFeedImage
	}
	
	func display(_ viewModel: FeedViewModel) {
		controller?.display(viewModel.feed.map { model in
			let adapter = FeedImageDataLoaderPresentationAdapter<WeakRefVirtualProxy<FeedImageCellController>, UIImage>(model: model, imageLoader: imageLoader)
			let view = FeedImageCellController(delegate: adapter, didSelectCell: { [weak self] in
				self?.didSelectFeedImage(model)
			})
			
			adapter.presenter = FeedImagePresenter(
				view: WeakRefVirtualProxy(view),
				imageTransformer: UIImage.init)
			
			return view
		})
	}
}
