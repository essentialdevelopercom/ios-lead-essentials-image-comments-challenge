//
//  CommentsLoaderPresentationAdapter.swift
//  EssentialApp
//
//  Created by Robert Dates on 1/23/21.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import Combine
import EssentialFeed
import EssentialFeediOS

public class CommentsLoaderPresentationAdapter : CommentsViewControllerDelegate {
	private let loader: () -> CommentLoader.Publisher
	private var cancellable: Cancellable?
	var presenter: CommentsPresenter?

	init(loader: @escaping () -> CommentLoader.Publisher) {
		self.loader = loader
	}

	public func didRequestCommentsRefresh() {
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
	}
}
