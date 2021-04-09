//
//  ImageCommentsPresentationAdapter.swift
//  EssentialApp
//
//  Created by Sebastian Vidrea on 09.04.2021.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import EssentialFeed
import EssentialFeediOS
import Combine

final class ImageCommentsPresentationAdapter: ImageCommentsViewControllerDelegate {
	var presenter: ImageCommentsPresenter?
	private let imageCommentsLoader: ImageCommentsLoader.Publisher
	private var cancellable: Cancellable?

	init(imageCommentsLoader: ImageCommentsLoader.Publisher) {
		self.imageCommentsLoader = imageCommentsLoader
	}

	func didRequestImageCommentsRefresh() {
		presenter?.didStartLoadingImageComments()

		cancellable = imageCommentsLoader
			.dispatchOnMainQueue()
			.sink { [weak self] completion in
				switch completion {
				case .finished: break

				case let .failure(error):
					self?.presenter?.didFinishLoadingImageComments(with: error)
				}
			} receiveValue: { [weak self] imageComments in
				self?.presenter?.didFinishLoadingImageComments(with: imageComments)
			}
	}

	func didCancelImageCommentsRequest() {
		cancellable?.cancel()
	}
}
