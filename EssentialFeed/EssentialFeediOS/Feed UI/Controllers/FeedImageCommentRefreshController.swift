//
//  FeedImageCommentRefreshController.swift
//  EssentialFeediOS
//
//  Created by Mario Alberto Barragán Espinosa on 12/02/21.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import UIKit
import EssentialFeed

public final class FeedImageCommentRefreshController: NSObject, FeedLoadingView {
	private(set) lazy var view: UIRefreshControl = loadView()

	private let loadComments: () -> Void

	public init(loadComments: @escaping () -> Void) {
		self.loadComments = loadComments
	}

	@objc func refresh() {
		loadComments()
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
