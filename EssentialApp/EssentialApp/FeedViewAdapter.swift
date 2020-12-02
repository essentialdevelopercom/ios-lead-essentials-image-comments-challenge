//
//  Copyright © 2019 Essential Developer. All rights reserved.
//

import UIKit
import EssentialFeed
import EssentialFeediOS

final class FeedViewAdapter: FeedView {
	private weak var controller: FeedViewController?
	private let imageLoader: (URL) -> FeedImageDataLoader.Publisher
	private let didSelectImage: (FeedImage) -> Void

	init(controller: FeedViewController, imageLoader: @escaping (URL) -> FeedImageDataLoader.Publisher, didSelectImage: @escaping (FeedImage) -> Void) {
		self.controller = controller
		self.imageLoader = imageLoader
		self.didSelectImage = didSelectImage
	}
	
	func display(_ viewModel: FeedViewModel) {
		controller?.display(viewModel.feed.map { model in
			let adapter = FeedImageDataLoaderPresentationAdapter<WeakRefVirtualProxy<FeedImageCellController>, UIImage>(model: model, imageLoader: imageLoader)
			let view = FeedImageCellController(
				delegate: adapter,
				didSelectImage: { [weak self] in
					self?.didSelectImage(model)
				})

			adapter.presenter = FeedImagePresenter(
				view: WeakRefVirtualProxy(view),
				imageTransformer: UIImage.init)
			
			return view
		})
	}
}
