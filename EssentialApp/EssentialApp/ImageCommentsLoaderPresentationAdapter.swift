//
//  ImageCommentsLoaderPresentationAdapter.swift
//  EssentialApp
//
//  Created by Cronay on 23.12.20.
//  Copyright © 2020 Essential Developer. All rights reserved.
//

import UIKit
import EssentialFeed
import EssentialFeediOS

final class ImageCommentsLoaderPresentationAdapter: ImageCommentsViewControllerDelegate {
	let loader: ImageCommentsLoader
	var presenter: ImageCommentsPresenter?
	var task: ImageCommentsLoaderTask?

	init(loader: ImageCommentsLoader) {
		self.loader = loader
	}

	func didRequestCommentsRefresh() {
		presenter?.didStartLoadingComments()
		task = loader.load { [weak self] result in
			switch result {
			case let .success(comments):
				self?.presenter?.didFinishLoadingComments(with: comments)

			case let .failure(error):
				self?.presenter?.didFinishLoadingComments(with: error)
			}
		}
	}

	func didCancelCommentsRequest() {
		task?.cancel()
	}
}
