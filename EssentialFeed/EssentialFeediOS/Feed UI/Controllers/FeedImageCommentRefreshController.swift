//
//  FeedImageCommentRefreshController.swift
//  EssentialFeediOS
//
//  Created by Mario Alberto Barragán Espinosa on 12/02/21.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import UIKit
import EssentialFeed

public protocol FeedRefreshViewControllerDelegate {
	func didRequestFeedCommentRefresh()
}

public final class FeedImageCommentRefreshController: NSObject, FeedLoadingView {
	private(set) lazy var view: UIRefreshControl = loadView()

	private let delegate: FeedRefreshViewControllerDelegate

	public init(delegate: FeedRefreshViewControllerDelegate) {
		self.delegate = delegate
	}

	@objc func refresh() {
		delegate.didRequestFeedCommentRefresh()
	}
	
	public func display(_ viewModel: FeedLoadingViewModel) {
		if viewModel.isLoading {
			view.beginRefreshing()
		} else {
			view.endRefreshing()
		}
	}
	
	private func loadView() -> UIRefreshControl {
		let view = UIRefreshControl()
		view.addTarget(self, action: #selector(refresh), for: .valueChanged)
		return view
	}
}
