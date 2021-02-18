//
//  FeedImageCommentLoaderPresentationAdapter.swift
//  EssentialApp
//
//  Created by Mario Alberto Barragán Espinosa on 17/02/21.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import Foundation
import EssentialFeed
import EssentialFeediOS

final class FeedImageCommentLoaderPresentationAdapter: FeedImageCommentViewControllerDelegate {
	private let feedCommentLoader: FeedImageCommentLoader
	var presenter: FeedImageCommentLoaderPresenter?
	private let url: URL

	init(feedCommentLoader: FeedImageCommentLoader, url: URL) {
		self.feedCommentLoader = feedCommentLoader
		self.url = url
	}
	
	func didRequestFeedCommentRefresh() {
		presenter?.didStartLoadingFeed()

		_ = feedCommentLoader.loadImageCommentData(from: url) { [weak self] result in
			switch result {
			case let .success(comments):
				self?.presenter?.didFinishLoadingFeed(with: comments)

			case let .failure(error):
				self?.presenter?.didFinishLoadingFeed(with: error)
			}
		}
	}
}
