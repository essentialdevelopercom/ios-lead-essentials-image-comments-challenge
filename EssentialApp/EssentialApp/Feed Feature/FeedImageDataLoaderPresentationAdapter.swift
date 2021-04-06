//
//  Copyright © 2019 Essential Developer. All rights reserved.
//

import Combine
import Foundation
import EssentialFeed
import EssentialFeediOS

final class FeedImageDataLoaderPresentationAdapter<View: FeedImageView, Image>: FeedImageCellControllerDelegate where View.Image == Image {
	private let model: FeedImage
	private let imageLoader: (URL) -> FeedImageDataLoader.Publisher
	private let router: FeedImageRouter
	private var cancellable: Cancellable?
	
	var presenter: FeedImagePresenter<View, Image>?
	
	init(model: FeedImage, 
		 imageLoader: @escaping (URL) -> FeedImageDataLoader.Publisher, 
		 router: FeedImageRouter) {
		self.model = model
		self.imageLoader = imageLoader
		self.router = router
	}
	
	func didRequestImage() {
		presenter?.didStartLoadingImageData(for: model)
		
		let model = self.model
		
		cancellable = imageLoader(model.url)
			.dispatchOnMainQueue()
			.sink(
				receiveCompletion: { [weak self] completion in
					switch completion {
					case .finished: break
						
					case let .failure(error):
						self?.presenter?.didFinishLoadingImageData(with: error, for: model)
					}
					
				}, receiveValue: { [weak self] data in
					self?.presenter?.didFinishLoadingImageData(with: data, for: model)
				})
	}
	
	func didCancelImageRequest() {
		cancellable?.cancel()
	}
	
	func didTapFeedImage() {
		router.goToComments(for: model)
	}
}
