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
	private let feedImageCommentsLoader: (String) -> FeedImageCommentsLoader.Publisher
	private var cancellable: Cancellable?
	private let feedImage: FeedImage
	
	var presenter: FeedImageCommentsPresenter?
	
	init(feedImage: FeedImage,
		 feedImageCommentsLoader: @escaping (String) -> FeedImageCommentsLoader.Publisher) {
		self.feedImage = feedImage
		self.feedImageCommentsLoader = feedImageCommentsLoader
	}
	
	func didRequestFeedImageCommentsRefresh() {
		presenter?.didStartLoadingComments()
		
		cancellable = feedImageCommentsLoader(feedImage.id.uuidString)
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
}
