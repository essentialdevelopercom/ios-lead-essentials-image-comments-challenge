//
//  ImageCommentsPresentationAdapter.swift
//  EssentialFeediOS
//
//  Created by Ángel Vázquez on 23/03/21.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import EssentialFeed
import Foundation

final class ImageCommentsPresentationAdapter: ImageCommentsRefreshViewControllerDelegate {
	private let url: URL
	private let loader: ImageCommentLoader
	var presenter: ImageCommentsListPresenter?
	
	private var task: ImageCommentLoaderTask?
	
	init(url: URL, loader: ImageCommentLoader) {
		self.url = url
		self.loader = loader
	}
	
	deinit {
		task?.cancel()
	}
	
	func didRequestLoadingComments() {
		presenter?.didStartLoadingComments()
		task = loader.load(from: url) { [weak self] result in
			switch result {
			case let .success(comments):
				self?.presenter?.didFinishLoadingComments(with: comments)
			case let .failure(error):
				self?.presenter?.didFinishLoadingComments(with: error)
			}
			self?.task = nil
		}
	}
}
