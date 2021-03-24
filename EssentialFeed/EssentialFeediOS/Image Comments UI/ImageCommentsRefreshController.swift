//
//  ImageCommentsRefreshController.swift
//  EssentialFeediOS
//
//  Created by Ángel Vázquez on 22/03/21.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import EssentialFeed
import UIKit

protocol ImageCommentsRefreshViewControllerDelegate {
	func didRequestLoadingComments()
}

final class ImageCommentsRefreshController: NSObject, ImageCommentLoadingView, ImageCommentErrorView {
	@IBOutlet private var refreshView: UIRefreshControl?
	private(set) lazy var errorView: CommentErrorView = makeErrorView()
	
	var delegate: ImageCommentsRefreshViewControllerDelegate?
	
	@IBAction func refreshComments() {
		delegate?.didRequestLoadingComments()
	}
	
	func display(_ viewModel: ImageCommentLoadingViewModel) {
		if viewModel.isLoading {
			refreshView?.beginRefreshing()
		} else {
			refreshView?.endRefreshing()
		}
	}
	
	func display(_ viewModel: ImageCommentErrorViewModel) {
		if let message = viewModel.message {
			errorView.show(message: message)
		} else {
			errorView.hideMessage()
		}
	}

	private func makeErrorView() -> CommentErrorView {
		let view = CommentErrorView()
		return view
	}
}
