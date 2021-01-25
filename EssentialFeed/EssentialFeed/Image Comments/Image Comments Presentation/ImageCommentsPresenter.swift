//
//  ImageCommentsPresenter.swift
//  EssentialFeed
//
//  Created by Lukas Bahrle Santana on 22/01/2021.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import Foundation


public struct ImageCommentsViewModel{
	public let imageComments: [ImageComment]
}

public struct ImageCommentsLoadingViewModel{
	public let isLoading: Bool
}

public struct ImageCommentsErrorViewModel{
	public let message: String?
	
	static var noError: ImageCommentsErrorViewModel {
		return ImageCommentsErrorViewModel(message: nil)
	}
}

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
	
	public static var title: String {
		return NSLocalizedString("IMAGE_COMMENTS_VIEW_TITLE",
			 tableName: "ImageComments",
			 bundle: Bundle(for: FeedPresenter.self),
			 comment: "Title for the image comments view")
	}
	
	public init(imageCommentsView: ImageCommentsView, loadingView: ImageCommentsLoadingView, errorView: ImageCommentsErrorView){
		self.imageCommentsView = imageCommentsView
		self.loadingView = loadingView
		self.errorView = errorView
	}
	
	public func didStartLoadingImageComments(){
		errorView.display(.noError)
		loadingView.display(ImageCommentsLoadingViewModel(isLoading: true))
	}
	
	public func didFinishLoadingImageComments(with imageComments: [ImageComment]) {
		imageCommentsView.display(ImageCommentsViewModel(imageComments: imageComments))
		loadingView.display(ImageCommentsLoadingViewModel(isLoading: false))
	}
}
