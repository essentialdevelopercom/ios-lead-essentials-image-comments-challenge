//
//  ImageCommentsUIComposer.swift
//  EssentialFeediOS
//
//  Created by Sebastian Vidrea on 03.04.2021.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import UIKit
import EssentialFeed
import EssentialFeediOS

public final class ImageCommentsUIComposer {
	private init() {}

	public static func imageCommentsComposedWith(imageCommentsLoader: ImageCommentsLoader) -> ImageCommentsViewController {
		let presentationAdapter = ImageCommentsPresentationAdapter(imageCommentsLoader: MainQueueDispatchDecorator(decoratee: imageCommentsLoader))

		let imageCommentsController = ImageCommentsViewController.makeWith(
			delegate: presentationAdapter,
			title: ImageCommentsPresenter.title
		)

		presentationAdapter.presenter = ImageCommentsPresenter(
			imageCommentsView: ImageCommentsViewAdapter(controller: imageCommentsController),
			imageCommentsLoadingView: WeakRefVirtualProxy(imageCommentsController),
			imageCommentsErrorView: WeakRefVirtualProxy(imageCommentsController)
		)

		return imageCommentsController
	}
}

private extension ImageCommentsViewController {
	static func makeWith(delegate: ImageCommentsViewControllerDelegate, title: String) -> ImageCommentsViewController {
		let bundle = Bundle(for: ImageCommentsViewController.self)
		let storyboard = UIStoryboard(name: "ImageComments", bundle: bundle)
		let imageCommentsController = storyboard.instantiateInitialViewController() as! ImageCommentsViewController
		imageCommentsController.delegate = delegate
		imageCommentsController.title = title
		return imageCommentsController
	}
}

private final class ImageCommentsViewAdapter: ImageCommentsView {
	private weak var controller: ImageCommentsViewController?

	private lazy var formattedDate = { (date: Date) -> String? in
		RelativeDateTimeFormatter().localizedString(for: date, relativeTo: Date())
	}

	init(controller: ImageCommentsViewController? = nil) {
		self.controller = controller
	}

	func display(_ viewModel: ImageCommentsViewModel) {
		controller?.display(viewModel.imageComments.map { model in
			let adapter = ImageCommentPresentationAdapter(imageComment: model)
			let view = ImageCommentCellController(delegate: adapter)

			adapter.presenter = ImageCommentPresenter(imageCommentView: WeakRefVirtualProxy(view), formattedDate: formattedDate)

			return view
		})
	}
}

private final class ImageCommentPresentationAdapter: ImageCommentCellControllerDelegate {
	private let imageComment: ImageComment
	var presenter: ImageCommentPresenter?

	init(imageComment: ImageComment) {
		self.imageComment = imageComment
	}

	func didLoadCell() {
		presenter?.shouldDisplayImageComment(imageComment)
	}

	func willReleaseCell() {
		presenter?.shouldDisplayNoImageComment()
	}
}

private final class ImageCommentsPresentationAdapter: ImageCommentsViewControllerDelegate {
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
