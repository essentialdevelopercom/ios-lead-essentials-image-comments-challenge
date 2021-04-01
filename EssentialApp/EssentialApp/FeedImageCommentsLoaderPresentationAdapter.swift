//
//  FeedImageCommentsLoaderPresentationAdapter.swift
//  EssentialApp
//
//  Created by Ivan Ornes on 22/3/21.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import Foundation
import Combine
import EssentialFeed
import EssentialFeediOS

final class FeedImageCommentsLoaderPresentationAdapter: FeedImageCommentsViewControllerDelegate {
	private let feedImageCommentsLoader: () -> FeedImageCommentsLoader.Publisher
	private var cancellable: Cancellable?
	
	var presenter: FeedImageCommentsPresenter?
	
	init(feedImageCommentsLoader: @escaping () -> FeedImageCommentsLoader.Publisher) {
		self.feedImageCommentsLoader = feedImageCommentsLoader
	}
	
	func didRequestFeedImageCommentsRefresh() {
		presenter?.didStartLoadingComments()
		
		cancellable = feedImageCommentsLoader()
			.dispatchOnMainQueue()
			.sink(
				receiveCompletion: { [weak self] completion in
					switch completion {
					case .finished: break
						
					case let .failure(error):
						self?.presenter?.didFinishLoadingComments(with: error)
					}
				}, receiveValue: { [weak self] comments in
					self?.presenter?.didFinishLoadingComments(with: comments)
				})
	}
	
	func didRequestFeedImageCommentsCancel() {
		cancellable?.cancel()
	}
}
