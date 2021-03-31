//
//  Copyright © 2019 Essential Developer. All rights reserved.
//

import UIKit
import EssentialFeed
import EssentialFeediOS

final class FeedViewAdapter: FeedView {
	private weak var controller: FeedViewController?
	private let imageLoader: (URL) -> FeedImageDataLoader.Publisher
	private let selectionHandler: (String) -> Void
	
	init(controller: FeedViewController, selectionHandler: @escaping (String) -> Void, imageLoader: @escaping (URL) -> FeedImageDataLoader.Publisher) {
		self.controller = controller
		self.selectionHandler = selectionHandler
		self.imageLoader = imageLoader
	}
	
	func display(_ viewModel: FeedViewModel) {
		controller?.display(viewModel.feed.map { model in
			let adapter = FeedImageDataLoaderPresentationAdapter<WeakRefVirtualProxy<FeedImageCellController>, UIImage>(model: model, imageLoader: imageLoader)
			let view = FeedImageCellController(
				cellControllerDelegate: adapter,
				selectionHandler: { [weak self] in
					self?.selectionHandler(model.id.uuidString)
				}
			)
			
			adapter.presenter = FeedImagePresenter(
				view: WeakRefVirtualProxy(view),
				imageTransformer: UIImage.init)
			
			return view
		})
	}
}
