//
//  Copyright © 2019 Essential Developer. All rights reserved.
//

import Foundation

public protocol FeedImageView {
	associatedtype Image
	
	func display(_ model: FeedImageViewModel<Image>)
}

public protocol FeedImageRouter {
	func goToComments(for feedImageID: String)
}

public final class FeedImagePresenter<View: FeedImageView, Image> where View.Image == Image {
	private let view: View
	private let imageTransformer: (Data) -> Image?
	private let router: FeedImageRouter
	
	public init(view: View, 
				imageTransformer: @escaping (Data) -> Image?,
				router: FeedImageRouter) {
		self.view = view
		self.imageTransformer = imageTransformer
		self.router = router
	}
	
	public func didStartLoadingImageData(for model: FeedImage) {
		view.display(FeedImageViewModel(
			description: model.description,
			location: model.location,
			image: nil,
			isLoading: true,
			shouldRetry: false))
	}
	
	public func didFinishLoadingImageData(with data: Data, for model: FeedImage) {
		let image = imageTransformer(data)
		view.display(FeedImageViewModel(
			description: model.description,
			location: model.location,
			image: image,
			isLoading: false,
			shouldRetry: image == nil))
	}
	
	public func didFinishLoadingImageData(with error: Error, for model: FeedImage) {
		view.display(FeedImageViewModel(
			description: model.description,
			location: model.location,
			image: nil,
			isLoading: false,
			shouldRetry: true))
	}
	
	public func didTapFeedImage(with id: String) {
		router.goToComments(for: id)
	}
}
