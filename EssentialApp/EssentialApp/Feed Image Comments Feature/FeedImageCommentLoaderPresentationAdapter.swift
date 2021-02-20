//
//  FeedImageCommentLoaderPresentationAdapter.swift
//  EssentialApp
//
//  Created by Mario Alberto Barragán Espinosa on 17/02/21.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import Foundation
import Combine
import EssentialFeed
import EssentialFeediOS

final class FeedImageCommentLoaderPresentationAdapter: FeedImageCommentViewControllerDelegate {
	private let feedCommentLoader: (URL) -> FeedImageCommentLoader.Publisher
	var presenter: FeedImageCommentLoaderPresenter?
	private let url: URL
	private var cancellable: Cancellable?

	init(feedCommentLoader: @escaping (URL) -> FeedImageCommentLoader.Publisher, url: URL) {
		self.feedCommentLoader = feedCommentLoader
		self.url = url
	}
	
	func didRequestFeedCommentRefresh() {
		presenter?.didStartLoadingFeedComments()

		cancellable = feedCommentLoader(url)
			.dispatchOnMainQueue()
			.sink(
				receiveCompletion: { [weak self] completion in
					switch completion {
					case .finished: break
						
					case let .failure(error):
						self?.presenter?.didFinishLoadingFeedComments(with: error)
					}
					
				}, receiveValue: { [weak self] comments in
					self?.presenter?.didFinishLoadingFeed(with: comments)
				})
	}
}
