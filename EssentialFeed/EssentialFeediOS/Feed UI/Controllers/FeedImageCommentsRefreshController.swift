//
//  FeedImageCommentsRefreshController.swift
//  EssentialFeediOS
//
//  Created by Anton Ilinykh on 09.03.2021.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import UIKit

public final class FeedImageCommentsRefreshController: NSObject {
	private(set) lazy var view = binded(UIRefreshControl())
	
	private let viewModel: FeedImageCommentsViewModel
	
	public init(viewModel: FeedImageCommentsViewModel) {
		self.viewModel = viewModel
	}
	
	private func binded(_ view: UIRefreshControl) -> UIRefreshControl {
		viewModel.onChange = { [weak view] viewModel in
			if viewModel.isLoading {
				view?.beginRefreshing()
			} else {
				view?.endRefreshing()
			}
		}
		view.addTarget(self, action: #selector(refresh), for: .valueChanged)
		return view
	}
	
	@objc func refresh() {
		viewModel.loadComments()
	}
}
