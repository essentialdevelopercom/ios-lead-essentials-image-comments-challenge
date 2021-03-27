//
//  ImageCommentsListPresenter.swift
//  EssentialFeed
//
//  Created by Ángel Vázquez on 26/03/21.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import Foundation

enum Localized {
	enum ImageComments {
		static var bundle = Bundle(for: ImageCommentsListPresenter.self)
		static var table: String { "ImageComments" }
		
		static var errorMessage: String {
			localizedString(
				for: "IMAGE_COMMENTS_VIEW_ERROR_MESSAGE",
				table: table,
				bundle: bundle,
				comment: "Error message to be presented when comments fail to load"
			)
		}
	}
	
	private static func localizedString(for key: String, table: String, bundle: Bundle, comment: String) -> String {
		NSLocalizedString(key, tableName: table, bundle: bundle, comment: comment)
	}
}

// MARK: - ViewModels

public struct ImageCommentsLoadingViewModel {
	public let isLoading: Bool
}

public struct ImageCommentsListViewModel {
	public let comments: [ImageComment]
}

public struct ImageCommentsErrorViewModel {
	public let message: String?
}

// MARK: - View Protocols

public protocol ImageCommentsLoadingView {
	func display(_ viewModel: ImageCommentsLoadingViewModel)
}

public protocol ImageCommentsListView {
	func display(_ viewModel: ImageCommentsListViewModel)
}

public protocol ImageCommentsErrorView {
	func display(_ viewModel: ImageCommentsErrorViewModel)
}

// MARK: - ImageCommentsListPresenter

public final class ImageCommentsListPresenter {
	
	private let loadingView: ImageCommentsLoadingView
	private let commentsView: ImageCommentsListView
	private let errorView: ImageCommentsErrorView
	
	public init(loadingView: ImageCommentsLoadingView, commentsView: ImageCommentsListView, errorView: ImageCommentsErrorView) {
		self.loadingView = loadingView
		self.commentsView = commentsView
		self.errorView = errorView
	}
	
	public func didStartLoadingComments() {
		loadingView.display(ImageCommentsLoadingViewModel(isLoading: true))
		errorView.display(ImageCommentsErrorViewModel(message: nil))
	}
	
	public func didFinishLoadingComments(with comments: [ImageComment]) {
		loadingView.display(ImageCommentsLoadingViewModel(isLoading: false))
		commentsView.display(ImageCommentsListViewModel(comments: comments))
	}
	
	public func didFinishLoadingComments(with error: Error) {
		loadingView.display(ImageCommentsLoadingViewModel(isLoading: false))
		errorView.display(ImageCommentsErrorViewModel(message: Localized.ImageComments.errorMessage))
	}
}
