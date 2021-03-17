//
//  ImageCommentsPresentationAdapter.swift
//  EssentialApp
//
//  Created by Adrian Szymanowski on 16/03/2021.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import Foundation
import Combine
import EssentialFeed
import EssentialFeediOS

final class ImageCommentsPresentationAdapter: ImageCommentsViewControllerDelegate {
	private let imageLoader: () -> ImageCommentsLoader.Publisher
	private var cancellable: Cancellable?
	var presenter: ImageCommentsPresenter?
	
	init(imageLoader: @escaping () -> ImageCommentsLoader.Publisher) {
		self.imageLoader = imageLoader
	}
	
	func didRequestImageCommentsRefresh() {
		presenter?.didStartLoadingComments()
		
		cancellable = imageLoader()
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
	
	func didCancelImageCommentsLoading() {
		cancellable?.cancel()
	}
	
}
