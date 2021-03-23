//
//  ImageCommentsUIComposer.swift
//  EssentialFeediOS
//
//  Created by Ángel Vázquez on 22/03/21.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import EssentialFeed
import Foundation

final class WeakReferenceVirtualProxy<T: AnyObject> {
	private weak var object: T?
	
	init(_ object: T) {
		self.object = object
	}
}

extension WeakReferenceVirtualProxy: ImageCommentLoadingView where T: ImageCommentLoadingView {
	func display(isLoading: Bool) {
		object?.display(isLoading: isLoading)
	}
}

extension WeakReferenceVirtualProxy: ImageCommentErrorView where T: ImageCommentErrorView {
	func display(message: String?) {
		object?.display(message: message)
	}
}

public final class ImageCommentsUIComposer {
	
	private init() {}
	
	public static func imageCommentsComposedWith(url: URL, currentDate: @escaping () -> Date, loader: ImageCommentLoader) -> ImageCommentsViewController {
		let presenter = ImageCommentsListPresenter(url: url, loader: loader)
		let refreshController = ImageCommentsRefreshController(presenter: presenter)
		let imageCommentsViewController = ImageCommentsViewController(refreshController: refreshController)
		let imageCommentsListView = ImageCommentsAdapter(controller: imageCommentsViewController, currentDate: currentDate)
		
		presenter.loadingView = WeakReferenceVirtualProxy(refreshController)
		presenter.errorView = WeakReferenceVirtualProxy(refreshController)
		presenter.commentsView = imageCommentsListView
		
		return imageCommentsViewController
	}
}

private final class ImageCommentsAdapter: ImageCommentsListView {
	weak var controller: ImageCommentsViewController?
	private let currentDate: () -> Date
	
	init(controller: ImageCommentsViewController, currentDate: @escaping () -> Date) {
		self.controller = controller
		self.currentDate = currentDate
	}
	
	func display(comments: [ImageComment]) {
		controller?.tableModel = comments.map { comment in
			ImageCommentsCellController(model: comment, currentDate: currentDate)
		}
	}
}
