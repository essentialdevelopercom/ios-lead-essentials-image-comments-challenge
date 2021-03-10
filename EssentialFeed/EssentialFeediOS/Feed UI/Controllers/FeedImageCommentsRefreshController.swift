//
//  FeedImageCommentsRefreshController.swift
//  EssentialFeediOS
//
//  Created by Anton Ilinykh on 09.03.2021.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import UIKit

final class FeedImageCommentsRefreshController: NSObject, FeedImageCommentLoadingView {
	private(set) lazy var view = loadView()
	
	private let loadFeed: () -> Void
	
	init(loadFeed: @escaping () -> Void) {
		self.loadFeed = loadFeed
	}
	
	func display(_ viewModel: FeedImageCommentLoadingViewModel) {
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
	
	@objc func refresh() {
		loadFeed()
	}
}
