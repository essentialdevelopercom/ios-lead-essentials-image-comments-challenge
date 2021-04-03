//
//  ImageCommentsUIComposer.swift
//  EssentialFeediOS
//
//  Created by Sebastian Vidrea on 03.04.2021.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import UIKit
import EssentialFeed

public final class ImageCommentsUIComposer {
	private init() {}

	public static func imageCommentsComposedWith(imageCommentsLoader: ImageCommentsLoader) -> ImageCommentsViewController {
		let presentationAdapter = ImageCommentsPresentationAdapter(imageCommentsLoader: imageCommentsLoader)
		let refreshController = ImageCommentsRefreshViewController(delegate: presentationAdapter)
		let imageCommentsController = ImageCommentsViewController(refreshController: refreshController)

		presentationAdapter.presenter = ImageCommentsPresenter(
			imageCommentsView: ImageCommentsViewAdapter(controller: imageCommentsController, imageCommentsLoader: imageCommentsLoader),
			imageCommentsLoadingView: WeakRefVirtualProxy(refreshController))
		
		return imageCommentsController
	}
}

private final class WeakRefVirtualProxy<T: AnyObject> {
	private weak var object: T?

	init(_ object: T) {
		self.object = object
	}
}

extension WeakRefVirtualProxy: ImageCommentsLoadingView where T: ImageCommentsLoadingView {
	func display(_ viewModel: ImageCommentsLoadingViewModel) {
		object?.display(viewModel)
	}
}

private final class ImageCommentsViewAdapter: ImageCommentsView {
	private weak var controller: ImageCommentsViewController?
	private let imageCommentsLoader: ImageCommentsLoader

	init(controller: ImageCommentsViewController? = nil, imageCommentsLoader: ImageCommentsLoader) {
		self.controller = controller
		self.imageCommentsLoader = imageCommentsLoader
	}

	func display(_ viewModel: ImageCommentsViewModel) {
		controller?.tableModel = viewModel.imageComments.map { model in
			ImageCommentCellController(viewModel: ImageCommentViewModel(model: model))
		}
	}
}

private final class ImageCommentsPresentationAdapter: ImageCommentsRefreshViewControllerDelegate {
	private let imageCommentsLoader: ImageCommentsLoader
	var presenter: ImageCommentsPresenter?

	init(imageCommentsLoader: ImageCommentsLoader) {
		self.imageCommentsLoader = imageCommentsLoader
	}

	func didRequestImageCommentsRefresh() {
		presenter?.didStartLoadingImageComments()

		imageCommentsLoader.load { [weak self] result in
			switch result {
			case let .success(imageComments):
				self?.presenter?.didFinishLoadingImageComments(with: imageComments)

			case let .failure(error):
				self?.presenter?.didFinishLoadingImageComments(with: error)
			}
		}
	}
}
