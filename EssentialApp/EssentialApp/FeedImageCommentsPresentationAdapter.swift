//
//  FeedImageCommentsPresentationAdapter.swift
//  EssentialApp
//
//  Created by Danil Vassyakin on 4/19/21.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import UIKit
import Combine
import EssentialFeed
import EssentialFeediOS

final class FeedImageCommentsPresentationAdapter: FeedCommentsViewControllerDelegate {
	private let loader: () -> FeedImageCommentLoader.Publisher
	private var cancellable: Cancellable?
	var presenter: FeedImageCommentPresenter?

	init(loader: @escaping () -> FeedImageCommentLoader.Publisher) {
		self.loader = loader
	}

	func didRequestCommentsRefresh() {
		presenter?.didStartLoadingComments()
		cancellable = loader()
			.dispatchOnMainQueue()
			.sink(receiveCompletion: { [weak self] completion in
				switch completion {
				   case .finished: break

				   case let .failure(error):
					   self?.presenter?.didFinishLoadingComments(with: error)
				   }
			   }, receiveValue: { [weak self] comments in
				   self?.presenter?.didFinishLoadingComments(with: comments)
			   })
	}

	deinit {
		cancellable?.cancel()
		cancellable = nil
	}
	
}
