//
//  ImageCommentsLoaderPresentationAdapter.swift
//  EssentialApp
//
//  Created by Cronay on 23.12.20.
//  Copyright © 2020 Essential Developer. All rights reserved.
//

import UIKit
import Combine
import EssentialFeed
import EssentialFeediOS

final class ImageCommentsLoaderPresentationAdapter: ImageCommentsViewControllerDelegate {
	let loader: () -> ImageCommentsLoader.Publisher
	private var cancellable: Cancellable?
	var presenter: ImageCommentsPresenter?

	init(loader: @escaping () -> ImageCommentsLoader.Publisher) {
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
	}
}
