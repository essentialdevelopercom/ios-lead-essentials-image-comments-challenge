//
//  ImageCommentLoaderPresentationAdapter.swift
//  EssentialApp
//
//  Created by Eric Garlock on 3/13/21.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import Foundation
import EssentialFeed
import EssentialFeediOS

class ImageCommentLoaderPresentationAdapter : ImageCommentsViewControllerDelegate {
	
	private var loader: ImageCommentLoader
	public var presenter: ImageCommentPresenter?
	private var cancellable: ImageCommentLoaderDataTask?
	
	init(loader: ImageCommentLoader) {
		self.loader = loader
	}
	
	deinit {
		cancellable?.cancel()
		cancellable = nil
	}
	
	func didRequestImageCommentsRefresh() {
		presenter?.didStartLoadingComments()
		cancellable = loader.load { [weak self] result in
			switch result {
			case let .success(imageComments):
				self?.presenter?.didFinishLoadingComments(with: imageComments)
			case let .failure(error):
				self?.presenter?.didFinishLoadingComments(with: error)
			}
		}
	}
	
}
