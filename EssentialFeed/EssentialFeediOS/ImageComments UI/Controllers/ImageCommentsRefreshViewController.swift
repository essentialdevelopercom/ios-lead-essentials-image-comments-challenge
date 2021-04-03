//
//  ImageCommentsRefreshViewController.swift
//  EssentialFeediOS
//
//  Created by Sebastian Vidrea on 03.04.2021.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import UIKit

final class ImageCommentsRefreshViewController: NSObject {
	private(set) lazy var view = binded(UIRefreshControl())

	private let viewModel: ImageCommentsViewModel

	init(viewModel: ImageCommentsViewModel) {
		self.viewModel = viewModel
	}

	@objc func refresh() {
		viewModel.loadImageComments()
	}

	private func binded(_ view: UIRefreshControl) -> UIRefreshControl {
		viewModel.onLoadingStateChange = { isLoading in
			if isLoading {
				view.beginRefreshing()
			} else {
				view .endRefreshing()
			}
		}
		view.addTarget(self, action: #selector(refresh), for: .valueChanged)
		return view
	}
}
