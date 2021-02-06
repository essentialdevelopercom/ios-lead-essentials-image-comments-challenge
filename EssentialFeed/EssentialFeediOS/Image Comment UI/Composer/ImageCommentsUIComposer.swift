//
//  ImageCommentsUIComposer.swift
//  EssentialFeediOS
//
//  Created by Alok Subedi on 06/02/2021.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import EssentialFeed

public class ImageCommentsUIComposer {
	public static func imageCommentsComposedWith(loader: ImageCommentsLoader) -> ImageCommentsViewController {
		let presentationAdapter = ImageCommentsPresentationAdapter(loader: loader)
		
		let imageCommentsViewController = ImageCommentsViewController(delegate: presentationAdapter)
		
		presentationAdapter.presenter = ImageCommentsPresenter(
			imageCommentsView: WeakRefVirtualProxy(imageCommentsViewController),
			loadingView: WeakRefVirtualProxy(imageCommentsViewController),
			errorView: WeakRefVirtualProxy(imageCommentsViewController)
		)
		
		return imageCommentsViewController
	}
}

class ImageCommentsPresentationAdapter: ImageCommentsViewControllerDelegate {
	private let loader: ImageCommentsLoader
	var presenter: ImageCommentsPresenter?
	
	init(loader: ImageCommentsLoader) {
		self.loader = loader
	}
	
	func didRequestImageCommentsRefresh() {
		presenter?.didStartLoadingImageComments()
		loader.load { [weak self] result in
			switch result {
			case let .success(imageComments):
				self?.presenter?.didFinishLoadingImageComments(with: imageComments)
				
			case let .failure(error):
				self?.presenter?.didFinishLoadingImageComments(with: error)
			}
		}
	}
}

class WeakRefVirtualProxy<T: AnyObject> {
	private weak var object: T?
	
	init(_ object: T) {
		self.object = object
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
	func display(_ viewModel: ImageCommentsViewModel) {
		object?.display(viewModel)
	}
}

