//
//  ImageCommentsPresenter.swift
//  EssentialFeed
//
//  Created by Araceli Ruiz Ruiz on 06/12/2020.
//  Copyright © 2020 Essential Developer. All rights reserved.
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
    
    public static var title: String {
        NSLocalizedString("COMMENTS_VIEW_TITLE",
                          tableName: "ImageComments",
                          bundle: Bundle(for: ImageCommentsPresenter.self),
                          comment: "Title for the comments view")
    }
    
    private var commentsLoadError: String {
        NSLocalizedString("COMMENTS_VIEW_CONNECTION_ERROR",
                          tableName: "ImageComments",
                          bundle: Bundle(for: ImageCommentsPresenter.self),
                          comment: "Error message displayed when we can't load the image comments from the server")
    }
    
	public init(imageCommentsView: ImageCommentsView, loadingView: ImageCommentsLoadingView, errorView: ImageCommentsErrorView, date: @escaping () -> Date = Date.init, locale: Locale = .current) {
        self.imageCommentsView = imageCommentsView
        self.loadingView = loadingView
        self.errorView = errorView
		self.currentDate = date
		self.locale = locale
    }
    
    public func didStartLoadingComments() {
        self.errorView.display(.noError)
        self.loadingView.display(ImageCommentsLoadingViewModel(isLoading: true))
    }
    
    public func didFinishLoadingComments(with comments: [ImageComment]) {
		imageCommentsView.display(ImageCommentsPresenter.map(comments, date: currentDate, locale: locale))
        loadingView.display(ImageCommentsLoadingViewModel(isLoading: false))
    }
    
    public func didFinishLoadingComments(with error: Error) {
        errorView.display(.error(message: commentsLoadError))
        loadingView.display(ImageCommentsLoadingViewModel(isLoading: false))
    }
	
	private static func map(_ comments: [ImageComment], date: @escaping () -> Date = Date.init, locale: Locale = .current) -> ImageCommentsViewModel {
		ImageCommentsViewModel(comments: comments.map {
			ImageCommentViewModel(
				message: $0.message,
				date: $0.createdAt.relativeDate(to: date(), locale: locale),
				username: $0.username)
		})
	}
}
