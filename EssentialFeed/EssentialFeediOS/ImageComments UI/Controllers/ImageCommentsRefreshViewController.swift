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
	private(set) lazy var view = loadView(UIRefreshControl())

	private let delegate: ImageCommentsRefreshViewControllerDelegate

	init(delegate: ImageCommentsRefreshViewControllerDelegate) {
		self.delegate = delegate
	}

	@objc func refresh() {
		delegate.didRequestImageCommentsRefresh()
	}

	func display(_ viewModel: ImageCommentsLoadingViewModel) {
		if viewModel.isLoading {
			view.beginRefreshing()
		} else {
			view.endRefreshing()
		}
	}

	private func loadView(_ view: UIRefreshControl) -> UIRefreshControl {
		view.addTarget(self, action: #selector(refresh), for: .valueChanged)
		return view
	}
}
