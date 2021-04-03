//
//  ImageCommentsUIComposer.swift
//  EssentialFeediOS
//
//  Created by Sebastian Vidrea on 03.04.2021.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import UIKit
import EssentialFeed

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

extension WeakRefVirtualProxy: ImageCommentView where T: ImageCommentView {
	func display(_ viewModel: ImageCommentViewModel) {
		object?.display(viewModel)
	}
}

public final class ImageCommentsUIComposer {
	private init() {}

	public static func imageCommentsComposedWith(imageCommentsLoader: ImageCommentsLoader) -> ImageCommentsViewController {
		let presentationAdapter = ImageCommentsPresentationAdapter(imageCommentsLoader: imageCommentsLoader)

		let bundle = Bundle(for: ImageCommentsViewController.self)
		let storyboard = UIStoryboard(name: "ImageComments", bundle: bundle)
		let imageCommentsController = storyboard.instantiateInitialViewController() as! ImageCommentsViewController
		let refreshController = imageCommentsController.refreshController!
		refreshController.delegate = presentationAdapter

		presentationAdapter.presenter = ImageCommentsPresenter(
			imageCommentsView: ImageCommentsViewAdapter(controller: imageCommentsController, imageCommentsLoader: imageCommentsLoader),
			imageCommentsLoadingView: WeakRefVirtualProxy(refreshController))

		return imageCommentsController
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
			let adapter = ImageCommentPresentationAdapter(imageComment: model)
			let view = ImageCommentCellController()

			adapter.presenter = ImageCommentPresenter(imageCommentView: WeakRefVirtualProxy(view))

			return view
		}
	}
}

private final class ImageCommentPresentationAdapter {
	private let imageComment: ImageComment
	var presenter: ImageCommentPresenter? {
		didSet {
			presenter?.shouldDisplayImageComment(imageComment)
		}
	}

	init(imageComment: ImageComment) {
		self.imageComment = imageComment
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
