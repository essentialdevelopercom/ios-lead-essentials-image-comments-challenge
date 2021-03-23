//
//  ImageCommentsRefreshController.swift
//  EssentialFeediOS
//
//  Created by Ángel Vázquez on 22/03/21.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import EssentialFeed
import UIKit

final class ImageCommentsRefreshController: NSObject {
	lazy var refreshView: UIRefreshControl = makeRefreshControl()
	lazy var errorView: CommentErrorView = makeErrorView()
	
	private let loader: ImageCommentLoader
	private let url: URL
	private var task: ImageCommentLoaderTask?
	
	var onCommentsLoad: ((_ comments: [ImageComment]) -> Void)?
	
	init(url: URL, loader: ImageCommentLoader) {
		self.url = url
		self.loader = loader
	}
	
	deinit {
		task?.cancel()
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
	
	@objc func refreshComments() {
		refreshView.beginRefreshing()
		errorView.hideMessage()
		task = loader.load(from: url) { [weak self] result in
			switch result {
			case let .success(comments):
				self?.onCommentsLoad?(comments)
			case .failure:
				self?.errorView.show(message: "Couldn't connect to server")
			}
			self?.refreshView.endRefreshing()
			self?.task = nil
		}
	}
}
