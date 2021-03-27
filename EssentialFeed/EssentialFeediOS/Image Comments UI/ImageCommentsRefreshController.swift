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

final class ImageCommentsRefreshController: NSObject, ImageCommentsLoadingView, ImageCommentsErrorView {
	@IBOutlet private var refreshView: UIRefreshControl?
	@IBOutlet private var errorView: CommentErrorView?
	
	var delegate: ImageCommentsRefreshViewControllerDelegate?
	
	@IBAction func refreshComments() {
		delegate?.didRequestLoadingComments()
	}
	
	func display(_ viewModel: ImageCommentsLoadingViewModel) {
		if viewModel.isLoading {
			refreshView?.beginRefreshing()
		} else {
			refreshView?.endRefreshing()
		}
	}
	
	func display(_ viewModel: ImageCommentsErrorViewModel) {
		if let message = viewModel.message {
			errorView?.show(message: message)
		} else {
			errorView?.hideMessage()
		}
	}
}
