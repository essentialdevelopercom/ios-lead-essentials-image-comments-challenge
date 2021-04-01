//
//  Copyright © 2019 Essential Developer. All rights reserved.
//

import UIKit
import EssentialFeed
import EssentialFeediOS

final class FeedViewAdapter: FeedView {
	private weak var controller: FeedViewController?
	private let imageLoader: (URL) -> FeedImageDataLoader.Publisher
	private let imageSelection: ((FeedImage) -> Void)?
	
	init(controller: FeedViewController,
		 imageLoader: @escaping (URL) -> FeedImageDataLoader.Publisher,
		 imageSelection: ((FeedImage) -> Void)?) {
		self.controller = controller
		self.imageLoader = imageLoader
		self.imageSelection = imageSelection
	}
	
	func display(_ viewModel: FeedViewModel) {
		controller?.display(viewModel.feed.compactMap { [weak self] model in
			guard let self = self else { return nil }
			let adapter = FeedImageDataLoaderPresentationAdapter<WeakRefVirtualProxy<FeedImageCellController>, UIImage>(model: model, imageLoader: self.imageLoader, imageSelection: self.imageSelection)
			let view = FeedImageCellController(delegate: adapter)
			
			adapter.presenter = FeedImagePresenter(
				view: WeakRefVirtualProxy(view),
				imageTransformer: UIImage.init)
			
			return view
		})
	}
}
