//
//  FeedImageCommentRefreshController.swift
//  EssentialFeediOS
//
//  Created by Mario Alberto Barragán Espinosa on 12/02/21.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import UIKit
import EssentialFeed

public final class FeedImageCommentRefreshController: NSObject {
	private(set) lazy var view: UIRefreshControl = binded(UIRefreshControl())

	private let viewModel: FeedImageCommentLoaderViewModel

	public init(viewModel: FeedImageCommentLoaderViewModel) {
		self.viewModel = viewModel
	}

	@objc func refresh() {
		viewModel.loadComments()
	}
	
	private func binded(_ view: UIRefreshControl) -> UIRefreshControl {
		viewModel.onLoadingStateChange = { [weak view] isLoading in
			if isLoading {
				view?.beginRefreshing()
			} else {
				view?.endRefreshing()
			}
		}
		view.addTarget(self, action: #selector(refresh), for: .valueChanged)
		return view
	}
}
