//
//  ImageCommentsPresenter.swift
//  EssentialFeed
//
//  Created by Lukas Bahrle Santana on 22/01/2021.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import Foundation


public protocol ImageCommentsView {
	func display(_ viewModel: ImageCommentsViewModel)
}

public protocol ImageCommentsLoadingView {
	func display(_ viewModel: ImageCommentsLoadingViewModel)
}

public protocol ImageCommentsErrorView {
	func display(_ viewModel: ImageCommentsErrorViewModel)
}

public final class ImageCommentsPresenter {
	private let imageCommentsView: ImageCommentsView
	private let loadingView: ImageCommentsLoadingView
	private let errorView: ImageCommentsErrorView
	
	private let currentDate: () -> Date
	private let locale: Locale
	private let calendar = Calendar(identifier: .gregorian)
	
	public static var title: String {
		return NSLocalizedString("IMAGE_COMMENTS_VIEW_TITLE",
			 tableName: "ImageComments",
			 bundle: Bundle(for: FeedPresenter.self),
			 comment: "Title for the image comments view")
	}
	
	public init(imageCommentsView: ImageCommentsView, loadingView: ImageCommentsLoadingView, errorView: ImageCommentsErrorView, currentDate: @escaping () -> Date = Date.init, locale: Locale = .current) {
		self.imageCommentsView = imageCommentsView
		self.loadingView = loadingView
		self.errorView = errorView
		self.currentDate = currentDate
		self.locale = locale
	}
	
	public func didStartLoadingImageComments() {
		errorView.display(.noError)
		loadingView.display(ImageCommentsLoadingViewModel(isLoading: true))
	}
	
	public func didFinishLoadingImageComments(with imageComments: [ImageComment]) {
		let presentableImageComments = imageComments.map {
			PresentableImageComment(message: $0.message, createdAt: formatDate(since: $0.createdAt), username: $0.author.username)
		}
		imageCommentsView.display(ImageCommentsViewModel(imageComments: presentableImageComments))
		loadingView.display(ImageCommentsLoadingViewModel(isLoading: false))
	}
	
	public func didFinishLoadingImageComments(with error: Error) {
		let errorMessage = NSLocalizedString("IMAGE_COMMENTS_VIEW_CONNECTION_ERROR",
											 tableName: "ImageComments",
					 bundle: Bundle(for: FeedPresenter.self),
					 comment: "Error message displayed when we can't load the image comments from the server")
		
		errorView.display(ImageCommentsErrorViewModel(message: errorMessage))
		loadingView.display(ImageCommentsLoadingViewModel(isLoading: false))
	}
	
	private func formatDate(since date: Date) -> String {
		let formatter = RelativeDateTimeFormatter()
		formatter.unitsStyle = .full
		formatter.locale = locale
		formatter.calendar = calendar
		return formatter.localizedString(for: date, relativeTo: currentDate())
	}
}
