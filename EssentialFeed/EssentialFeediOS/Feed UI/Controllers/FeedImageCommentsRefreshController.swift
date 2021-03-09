//
//  FeedImageCommentsRefreshController.swift
//  EssentialFeediOS
//
//  Created by Anton Ilinykh on 09.03.2021.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import UIKit
import EssentialFeed

public final class FeedImageCommentsRefreshController: NSObject {
	private(set) lazy var view: UIRefreshControl = {
		let view = UIRefreshControl()
		view.addTarget(self, action: #selector(refresh), for: .valueChanged)
		return view
	}()
	
	private let commentsLoader: FeedImageCommentsLoader
	
	public init(commentsLoader: FeedImageCommentsLoader) {
		self.commentsLoader = commentsLoader
	}
	
	var onRefresh: (([FeedImageComment]) -> Void)?
	
	@objc func refresh() {
		view.beginRefreshing()
		commentsLoader.load { [weak self] result in
			if let comments = try? result.get() {
				self?.onRefresh?(comments)
			}
			self?.view.endRefreshing()
		}
	}
}
