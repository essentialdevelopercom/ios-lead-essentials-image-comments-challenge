//
//  ImageCommentsRefreshController.swift
//  EssentialFeediOS
//
//  Created by Ángel Vázquez on 22/03/21.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import EssentialFeed
import UIKit

public protocol ImageCommentsRefreshViewControllerDelegate {
	func didRequestLoadingComments()
}

public final class ImageCommentsRefreshController: NSObject, ImageCommentsLoadingView, ImageCommentsErrorView {
	@IBOutlet private var refreshView: UIRefreshControl?
	@IBOutlet private var errorView: ErrorView?
	
	public var delegate: ImageCommentsRefreshViewControllerDelegate?
	
	@IBAction func refreshComments() {
		delegate?.didRequestLoadingComments()
	}
	
	public func display(_ viewModel: ImageCommentsLoadingViewModel) {
		if viewModel.isLoading {
			refreshView?.beginRefreshing()
		} else {
			refreshView?.endRefreshing()
		}
	}
	
	public func display(_ viewModel: ImageCommentsErrorViewModel) {
		errorView?.message = viewModel.message
	}
}
