//
//  ImageCommentsRefreshViewController.swift
//  EssentialFeediOS
//
//  Created by Sebastian Vidrea on 03.04.2021.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import UIKit
import EssentialFeed

protocol ImageCommentsRefreshViewControllerDelegate {
	func didRequestImageCommentsRefresh()
}

final class ImageCommentsRefreshViewController: NSObject, ImageCommentsLoadingView {
	@IBOutlet private(set) var view: UIRefreshControl?

	var delegate: ImageCommentsRefreshViewControllerDelegate?

	@IBAction func refresh() {
		delegate?.didRequestImageCommentsRefresh()
	}

	func display(_ viewModel: ImageCommentsLoadingViewModel) {
		if viewModel.isLoading {
			view?.beginRefreshing()
		} else {
			view?.endRefreshing()
		}
	}
}
