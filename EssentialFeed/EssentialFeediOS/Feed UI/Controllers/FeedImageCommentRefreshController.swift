//
//  FeedImageCommentRefreshController.swift
//  EssentialFeediOS
//
//  Created by Mario Alberto Barragán Espinosa on 12/02/21.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import UIKit
import EssentialFeed

final class FeedImageCommentRefreshController: NSObject {
	private(set) lazy var view: UIRefreshControl = {
		let view = UIRefreshControl()
		view.addTarget(self, action: #selector(refresh), for: .valueChanged)
		return view
	}()

	private let feedCommentLoader: FeedImageCommentLoader
	private let url: URL

	init(feedCommentLoader: FeedImageCommentLoader, url: URL) {
		self.feedCommentLoader = feedCommentLoader
		self.url = url
	}

	var onRefresh: (([FeedImageComment]) -> Void)?

	@objc func refresh() {
		view.beginRefreshing()
		_ = feedCommentLoader.loadImageCommentData(from: url) { [weak self] result in
			if let comments = try? result.get() {
				self?.onRefresh?(comments)
			}
			self?.view.endRefreshing()
		}
	}
}
