//
//  ImageCommentsRefreshController.swift
//  EssentialFeediOS
//
//  Created by Ángel Vázquez on 22/03/21.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import EssentialFeed
import UIKit

protocol ImageCommentLoadingView {
	func display(isLoading: Bool)
}

protocol ImageCommentsListView {
	func display(comments: [ImageComment])
}

protocol ImageCommentErrorView {
	func display(message: String?)
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
		loadingView?.display(isLoading: true)
		errorView?.display(message: nil)
		
		task = loader.load(from: url) { [weak self] result in
			switch result {
			case let .success(comments):
				self?.commentsView?.display(comments: comments)
			case .failure:
				self?.errorView?.display(message: "Couldn't connect to server")
			}
			self?.loadingView?.display(isLoading: false)
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
	
	func display(isLoading: Bool) {
		if isLoading {
			refreshView.beginRefreshing()
		} else {
			refreshView.endRefreshing()
		}
	}
	
	func display(message: String?) {
		if let message = message {
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
