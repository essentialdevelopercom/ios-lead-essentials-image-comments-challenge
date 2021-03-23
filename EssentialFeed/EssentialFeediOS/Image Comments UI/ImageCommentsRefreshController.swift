//
//  ImageCommentsRefreshController.swift
//  EssentialFeediOS
//
//  Created by Ángel Vázquez on 22/03/21.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import EssentialFeed
import UIKit

struct ImageCommentLoadingViewModel {
	let isLoading: Bool
}

protocol ImageCommentLoadingView {
	func display(_ viewModel: ImageCommentLoadingViewModel)
}

struct ImageCommentsListViewModel {
	let comments: [ImageComment]
}

protocol ImageCommentsListView {
	func display(_ viewModel: ImageCommentsListViewModel)
}

struct ImageCommentErrorViewModel {
	let message: String?
}

protocol ImageCommentErrorView {
	func display(_ viewModel: ImageCommentErrorViewModel)
}

final class ImageCommentsListPresenter {
	private let url: URL
	private let loader: ImageCommentLoader
	private var task: ImageCommentLoaderTask?
	
	var loadingView: ImageCommentLoadingView?
	var commentsView: ImageCommentsListView?
	var errorView: ImageCommentErrorView?
	
	init(url: URL, loader: ImageCommentLoader) {
		self.url = url
		self.loader = loader
	}
	
	deinit {
		task?.cancel()
	}
	
	func loadComments() {
		loadingView?.display(ImageCommentLoadingViewModel(isLoading: true))
		errorView?.display(ImageCommentErrorViewModel(message: nil))
		
		task = loader.load(from: url) { [weak self] result in
			switch result {
			case let .success(comments):
				self?.commentsView?.display(ImageCommentsListViewModel(comments: comments))
			case .failure:
				self?.errorView?.display(ImageCommentErrorViewModel(message: "Couldn't connect to server"))
			}
			self?.loadingView?.display(ImageCommentLoadingViewModel(isLoading: false))
			self?.task = nil
		}
	}
}

final class ImageCommentsRefreshController: NSObject, ImageCommentLoadingView, ImageCommentErrorView {
	private(set) lazy var refreshView: UIRefreshControl = makeRefreshControl()
	private(set) lazy var errorView: CommentErrorView = makeErrorView()
	
	private let presenter: ImageCommentsListPresenter
	
	init(presenter: ImageCommentsListPresenter) {
		self.presenter = presenter
	}
	
	@objc
	func refreshComments() {
		presenter.loadComments()
	}
	
	func display(_ viewModel: ImageCommentLoadingViewModel) {
		if viewModel.isLoading {
			refreshView.beginRefreshing()
		} else {
			refreshView.endRefreshing()
		}
	}
	
	func display(_ viewModel: ImageCommentErrorViewModel) {
		if let message = viewModel.message {
			errorView.show(message: message)
		} else {
			errorView.hideMessage()
		}
	}
	
	private func makeRefreshControl() -> UIRefreshControl {
		let control = UIRefreshControl()
		control.addTarget(self, action: #selector(refreshComments), for: .valueChanged)
		return control
	}
	
	private func makeErrorView() -> CommentErrorView {
		let view = CommentErrorView()
		return view
	}
}
