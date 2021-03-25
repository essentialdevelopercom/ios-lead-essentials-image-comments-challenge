//
//  ImageCommentsListPresenter.swift
//  EssentialFeediOS
//
//  Created by Ángel Vázquez on 23/03/21.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import EssentialFeed
import Foundation

// MARK: - ViewModels

struct ImageCommentLoadingViewModel {
	let isLoading: Bool
}

struct ImageCommentsListViewModel {
	let comments: [ImageComment]
}

struct ImageCommentErrorViewModel {
	let message: String?
}

// MARK: - View Protocols

protocol ImageCommentLoadingView {
	func display(_ viewModel: ImageCommentLoadingViewModel)
}

protocol ImageCommentsListView {
	func display(_ viewModel: ImageCommentsListViewModel)
}

protocol ImageCommentErrorView {
	func display(_ viewModel: ImageCommentErrorViewModel)
}

// MARK: - ImageCommentsListPresenter

final class ImageCommentsListPresenter {
	private let loadingView: ImageCommentLoadingView
	private let commentsView: ImageCommentsListView
	private let errorView: ImageCommentErrorView
	
	init(loadingView: ImageCommentLoadingView, commentsView: ImageCommentsListView, errorView: ImageCommentErrorView) {
		self.loadingView = loadingView
		self.commentsView = commentsView
		self.errorView = errorView
	}
	
	func didStartLoadingComments() {
		loadingView.display(ImageCommentLoadingViewModel(isLoading: true))
		errorView.display(ImageCommentErrorViewModel(message: nil))
	}
	
	func didFinishLoadingComments(with comments: [ImageComment]) {
		loadingView.display(ImageCommentLoadingViewModel(isLoading: false))
		commentsView.display(ImageCommentsListViewModel(comments: comments))
	}
	
	func didFinishLoadingComments(with error: Error) {
		loadingView.display(ImageCommentLoadingViewModel(isLoading: false))
		errorView.display(ImageCommentErrorViewModel(message: Localized.ImageComments.errorMessage))
	}
}
