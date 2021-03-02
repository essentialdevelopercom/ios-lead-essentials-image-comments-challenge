//
//  ImageCommentsPresentationAdapter.swift
//  EssentialApp
//
//  Created by alok subedi on 02/03/2021.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import EssentialFeed
import EssentialFeediOS
import Combine

class ImageCommentsPresentationAdapter: ImageCommentsViewControllerDelegate {
	private var cancellable: Cancellable?
	private let loader: () -> ImageCommentsLoader.Publisher
	var presenter: ImageCommentsPresenter?
	
	init(loader: @escaping () -> ImageCommentsLoader.Publisher) {
		self.loader = loader
	}
	
	func didRequestImageCommentsRefresh() {
		presenter?.didStartLoadingImageComments()
		cancellable = loader()
			.dispatchOnMainQueue()
			.sink(receiveCompletion: { [weak self] completion in
				switch completion {
				case .finished: break
					
				case let .failure(error):
					self?.presenter?.didFinishLoadingImageComments(with: error)
				}
			}, receiveValue: { [weak self] comments in
				self?.presenter?.didFinishLoadingImageComments(with: comments)
			})
	}
	
	deinit {
		cancellable?.cancel()
	}
}
