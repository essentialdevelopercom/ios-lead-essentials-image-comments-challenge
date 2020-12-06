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
    
    private var commentsLoadError: String {
        NSLocalizedString("COMMENTS_VIEW_CONNECTION_ERROR",
                          tableName: "ImageComments",
                          bundle: Bundle(for: ImageCommentsPresenter.self),
                          comment: "Error message displayed when we can't load the image comments from the server")
    }
    
    public init(imageCommentsView: ImageCommentsView, loadingView: ImageCommentsLoadingView, errorView: ImageCommentsErrorView) {
        self.imageCommentsView = imageCommentsView
        self.loadingView = loadingView
        self.errorView = errorView
    }
    
    public func didStartLoadingComments() {
        errorView.display(.noError)
        loadingView.display(ImageCommentsLoadingViewModel(isLoading: true))
    }
    
    public func didFinishLoadingComments(with comments: [ImageComment]) {
        imageCommentsView.display(ImageCommentsViewModel(comments: comments))
        loadingView.display(ImageCommentsLoadingViewModel(isLoading: false))
    }
    
    public func didFinishLoadingComments(with error: Error) {
        errorView.display(.error(message: commentsLoadError))
        loadingView.display(ImageCommentsLoadingViewModel(isLoading: false))
    }
}
