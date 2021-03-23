//
//  ImageCommentsUIComposer.swift
//  EssentialFeediOS
//
//  Created by Ángel Vázquez on 22/03/21.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import EssentialFeed
import Foundation

final class WeakReferenceVirtualProxy<T: AnyObject> {
	private weak var object: T?
	
	init(_ object: T) {
		self.object = object
	}
}

extension WeakReferenceVirtualProxy: ImageCommentLoadingView where T: ImageCommentLoadingView {
	func display(_ viewModel: ImageCommentLoadingViewModel) {
		object?.display(viewModel)
	}
}

extension WeakReferenceVirtualProxy: ImageCommentErrorView where T: ImageCommentErrorView {
	func display(_ viewModel: ImageCommentErrorViewModel) {
		object?.display(viewModel)
	}
}

public final class ImageCommentsUIComposer {
	
	private init() {}
	
	public static func imageCommentsComposedWith(url: URL, currentDate: @escaping () -> Date, loader: ImageCommentLoader) -> ImageCommentsViewController {
		let presenter = ImageCommentsListPresenter()
		let presentationAdapter = ImageCommentsPresentationAdapter(url: url, loader: loader, presenter: presenter)
		let refreshController = ImageCommentsRefreshController(loadComments: presentationAdapter.loadComments)
		let imageCommentsViewController = ImageCommentsViewController(refreshController: refreshController)
		let imageCommentsListView = ImageCommentsAdapter(controller: imageCommentsViewController, currentDate: currentDate)
		
		presenter.loadingView = WeakReferenceVirtualProxy(refreshController)
		presenter.errorView = WeakReferenceVirtualProxy(refreshController)
		presenter.commentsView = imageCommentsListView
		
		return imageCommentsViewController
	}
}

private final class ImageCommentsAdapter: ImageCommentsListView {
	weak var controller: ImageCommentsViewController?
	private let currentDate: () -> Date
	
	init(controller: ImageCommentsViewController, currentDate: @escaping () -> Date) {
		self.controller = controller
		self.currentDate = currentDate
	}
	
	func display(_ viewModel: ImageCommentsListViewModel) {
		controller?.tableModel = viewModel.comments.map { comment in
			ImageCommentsCellController(model: comment, currentDate: currentDate)
		}
	}
}

private final class ImageCommentsPresentationAdapter {
	private let url: URL
	private let loader: ImageCommentLoader
	private let presenter: ImageCommentsListPresenter
	
	private var task: ImageCommentLoaderTask?
	
	init(url: URL, loader: ImageCommentLoader, presenter: ImageCommentsListPresenter) {
		self.url = url
		self.loader = loader
		self.presenter = presenter
	}
	
	deinit {
		task?.cancel()
	}
	
	func loadComments() {
		presenter.didStartLoadingComments()
		task = loader.load(from: url) { [weak self] result in
			switch result {
			case let .success(comments):
				self?.presenter.didFinishLoadingComments(with: comments)
			case let .failure(error):
				self?.presenter.didFinishLoadingComments(with: error)
			}
			self?.task = nil
		}
	}
}
