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
		let presentationAdapter = ImageCommentsPresentationAdapter(url: url, loader: loader)
		let refreshController = ImageCommentsRefreshController(delegate: presentationAdapter)
		let imageCommentsViewController = ImageCommentsViewController(refreshController: refreshController)
		
		let imageCommentsListView = ImageCommentsAdapter(
			controller: imageCommentsViewController,
			currentDate: currentDate
		)
		
		let presenter = ImageCommentsListPresenter(
			loadingView: WeakReferenceVirtualProxy(refreshController),
			commentsView: imageCommentsListView,
			errorView: WeakReferenceVirtualProxy(refreshController)
		)
		
		presentationAdapter.presenter = presenter
		
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

private final class ImageCommentsPresentationAdapter: ImageCommentsRefreshViewControllerDelegate {
	private let url: URL
	private let loader: ImageCommentLoader
	var presenter: ImageCommentsListPresenter?
	
	private var task: ImageCommentLoaderTask?
	
	init(url: URL, loader: ImageCommentLoader) {
		self.url = url
		self.loader = loader
	}
	
	deinit {
		task?.cancel()
	}
	
	func didRequestLoadingComments() {
		presenter?.didStartLoadingComments()
		task = loader.load(from: url) { [weak self] result in
			switch result {
			case let .success(comments):
				self?.presenter?.didFinishLoadingComments(with: comments)
			case let .failure(error):
				self?.presenter?.didFinishLoadingComments(with: error)
			}
			self?.task = nil
		}
	}
}
