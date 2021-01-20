//
//  CommentLoaderPresentationAdapter.swift
//  EssentialFeediOS
//
//  Created by Khoi Nguyen on 5/1/21.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import Foundation
import EssentialFeed
import EssentialFeediOS

class CommentLoaderPresentationAdapter: CommentViewControllerDelegate {

	private let commentLoader: CommentLoader
	var presenter: CommentPresenter?
	private var task: CommentLoaderTask?
	
	init(commentLoader: CommentLoader) {
		self.commentLoader = commentLoader
	}
	
	func didRequestCommentRefresh() {
		presenter?.didStartLoadingComment()
		task = commentLoader.load { [weak self] result in
			switch result {
			case let .success(comments):
				self?.presenter?.didFinishLoadingComment(with: comments)
			case let .failure(error):
				self?.presenter?.didFinishLoadingComment(with: error)
			}
		}
	}
	
	deinit {
		task?.cancel()
	}
}
